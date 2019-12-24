#!/usr/bin/env python3
import sys
import telnetlib
import os
import platform
import datetime
import glob
import hashlib
import ipaddress
import logging

login = "login"
password = "pass"
enablePassword = "password"
startip = "192.168.1.1"
endip   = "192.168.1.10"
timeout = "5"

logname = "backup.log"
loglevel = logging.INFO # DEBUG,INFO,WARNING,ERROR,CRITICAL
diff_cmd = "/usr/bin/diff"


class LoggerWriter:
    def __init__(self, level):
        # self.level is really like using log.debug(message)
        # at least in my case
        self.level = level

    def write(self, message):
        # if statement reduces the amount of newlines that are
        # printed to the logger
        if message != '\n':
            self.level(message)

    def flush(self):
        # create a flush method so things can be flushed when
        # the system wants to. Not sure if simply 'printing'
        # sys.stderr is the correct way to do it, but it seemed
        # to work properly for me.
        #self.level(sys.stderr)
        pass

class CTerm:
    """Cisco console"""

    def __init__(self, ip, password,  login=None, enablePassword=None, timeout="5"):
        self.mode = ""
        self.ip = ip
        self.password = password
        self.login = login
        self.enablePassword = enablePassword
        self.timeout = int(timeout)

        try:
            self.terminal = telnetlib.Telnet()
            self.terminal.open(self.ip, 23, self.timeout)
        except Exception as e:
            raise Exception("Connection error ({}): {} ".format(self.ip, str(e)))
        else:
            self.cisco_login =  self.telnet_cisco_login
            self.enter = self.telnet_enter
            self.try_enable = self.telnet_try_enable
            try:
                self.cisco_login()
            except:
                raise

    def telnet_cisco_login(self):
        try:
            lpr = self.terminal.expect([b"Username: ",
                                                         b"Password: "])
            if lpr[0] == 0:
                """ Username and password authentication"""
                login = self.login + "\n"
                password = self.password + "\n"
                self.terminal.write(login.encode("utf-8"))
                self.terminal.read_until("Password: ".encode("utf-8"))
                self.terminal.write(password.encode("utf-8"))
                cpr = self.terminal.expect([b">", b"#", b"Username: "])
                if cpr[0] == 0 :
                    self.mode = ">"
                    self.enter("terminal length 0")
                elif cpr[0] == 1:
                    self.mode = "#"
                    self.enter("terminal length 0")
                elif cpr[0] == 2:
                    raise Exception("Invalid login or password")
            elif lpr[0] == 1:
                """ Password only authentication"""
                password = self.password + "\n"
                self.terminal.write(password.encode("utf-8"))
                cpr = self.terminal.expect([b">", b"#", b"Password: "])
                if cpr[0] == 0 :
                    self.mode = ">"
                    self.enter("terminal length 0")
                elif cpr[0] == 1:
                    self.mode = "#"
                    self.enter("terminal length 0")
                elif cpr[0] == 2:
                    raise Exception("Invalid password")
                
        except Exception as e:
            raise Exception("Login error ({}): {} ".format(self.ip, str(e)))

    def telnet_try_enable(self):
        if self.mode == ">" and self.enablePassword is not None:
            try:
                enablePassword = self.enablePassword + "\n"
                self.enter("enable", "Password: ")
                self.terminal.write(enablePassword.encode("utf-8"))
                epr = self.terminal.expect([b"#", b"Password: "])
                if epr[0] == 0:
                    self.mode = "#"
                elif epr[0] == 1:
                    raise Exception("Invalid enable password")
            except Exception as e:
                raise Exception("Enable error ({}): {} ".format(self.ip, str(e)))
        elif  self.mode == ">" and self.enablePassword is None:
            raise Exception("Enable error ({}): enable password is not set ".format(self.ip))
            
            
        

    def telnet_enter(self, message, answer=None, timeout=None, loginProcedure=None):
        if answer == None:
            answer = self.mode
        if timeout == None:
            timeout = self.timeout
        command = message + "\n"
        self.terminal.write(command.encode("utf-8"))
        result = self.terminal.read_until(answer.encode("utf-8"), timeout).decode("utf-8")
        result = "\n".join(result.split("\n")[:-1])
        return result

    def get_config(self):
        config = self.enter("sh ru | exclude ntp clock-period")
        config = config[config.find('!'):]
        while config.startswith("!"):
            config = "\n".join(config.split("\n")[1:])
        return config

    def show_ip(self):
        print(self.ip)

def unhandled_exception(exc_type, exc_value, exc_traceback):
    logger.critical("Uncaught exception", exc_info=(exc_type, exc_value, exc_traceback))
    sys.exit(1)

sys.excepthook = unhandled_exception

start_ip = ipaddress.IPv4Address(startip)
end_ip = ipaddress.IPv4Address(endip)

#dirs
scriptdir = os.path.dirname(os.path.abspath(__file__))
workdir = os.path.join(scriptdir, "backup")
os.makedirs(workdir, exist_ok=True)
# logging
logfile = os.path.join(workdir, logname)
logging.basicConfig(handlers=[logging.FileHandler(logfile, 'a', 'utf-8-sig')],
        format="%(asctime)-15s\tline:%(lineno)-6d\t%(message)s",
                    level=logging.DEBUG)
logger = logging.getLogger(name="main")
sys.stdout = LoggerWriter(logger.warning)
sys.stderr = LoggerWriter(logger.warning)
logger.setLevel(logging.DEBUG)


for ipaddr in range(int(start_ip), int(end_ip) +1):
    ipStr = str(ipaddress.IPv4Address(ipaddr))
    logger.debug(ipStr)
    try:
        cisco = CTerm(ipStr, password, login, enablePassword,  timeout=timeout)
        cisco.try_enable()
    except Exception as e:
        logger.debug(str(e))
    else:
        try:
            backupdir = os.path.join(workdir, ipStr)
            os.makedirs(backupdir, exist_ok=True)
        except Exception as e:
            print(e)
        dt = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
        newconffile = os.path.join(backupdir, dt + ".conf")
        tmpconffile = os.path.join(workdir, dt + ".conf")
        config = cisco.get_config()
        try:
            lastconffile = sorted(glob.glob(backupdir+"/*.conf"))[-1]
        except:
            logger.debug("There is no saved config file for this device")
            try:
                with open(newconffile, "w") as f:
                    f.write(config)
            except Exception as e:
                logger.error("Fail to write new config file: " + e)
            else:
                logger.info("New config file saved: " + newconffile)
        else:
            logger.debug("Previously created config file found: " + lastconffile)
            try:
                with open(tmpconffile, "w") as f:
                    f.write(config)
            except Exception as e:
                logger.error("Fail to write tmp config file: " + e)
            else:
                logger.debug("Config saved to temporary config file: " + tmpconffile)
                logger.debug("Checking md5")
                with open(tmpconffile, "rb") as f:
                    tmphash = hashlib.md5(f.read()).hexdigest()
                with open(lastconffile, "rb") as f:
                    oldhash = hashlib.md5(f.read()).hexdigest()
                if tmphash == oldhash:
                    logger.debug("Config was not changed")
                    os.remove(tmpconffile)
                    logger.debug("Temporary config file removed")
                else:
                    logger.debug("Config was changed")
                    os.rename(tmpconffile, newconffile)
                    logger.debug("Temporary config file moved to device folder")
                    logger.info("New config file saved: " + newconffile)
                    os.system(diff_cmd + " " + lastconffile + " " + newconffile + " > " + newconffile + ".diff")
                    logger.debug("Diff saved: " + newconffile + ".diff")

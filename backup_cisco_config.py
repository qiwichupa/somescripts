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
password = "pa$$word"
startip = "192.168.1.1"
endip   = "192.168.1.20"
timeout = "2"

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
        self.answer = ">"
        self.ip = ip
        self.password = password
        self.login = login
        self.enablePassword = enablePassword
        self.timeout = int(timeout)

        try:
            self.terminal = telnetlib.Telnet()
            self.terminal.open(self.ip, 23, self.timeout)
        except:
            raise Exception("Connection timeout")
        else:
            self.cisco_login()

    def cisco_login(self):
        try:
            self.terminal.read_until("Username: ".encode("utf-8"))
            self.enter(login, "Password: ")
            self.enter(password,"#")
            self.answer = "#"
            self.enter("terminal length 0")
        except Exception as e:
            print("Login error: " + e)

    def enter(self, message, answer=None, timeout=None, loginProcedure=None):
        if answer == None:
            answer = self.answer
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
        #config = "\n".join(config.split("\n")[:-1])
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
logger.setLevel(logging.INFO)


for ipaddr in range(int(start_ip), int(end_ip) +1):
    ipStr = str(ipaddress.IPv4Address(ipaddr))
    logger.debug(ipStr)
    try:
        cisco = CTerm(ipStr, password, login, timeout=timeout)
    except Exception as e:
        logger.debug(e)
    else:
        try:
            backupdir = os.path.join(workdir, ipStr)
            os.makedirs(backupdir, exist_ok=True)
        except Exception as e:
            print(e)
        dt = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
        newconffile = os.path.join(backupdir, dt + ".conf")
        config = cisco.get_config()
        try:
            lastconffile = sorted(glob.glob(backupdir+"/*.conf"))[-1]
        except:
            try:
                with open(newconffile, "w") as f:
                    f.write(config)
            except Exception as e:
                logger.error("Fail to write new config file: " + e)
            else:
                logger.info("New config file saved: " + newconffile)
        else:
            logger.debug("Last config file found: " + lastconffile)
            try:
                with open(newconffile, "w") as f:
                    f.write(config)
            except Exception as e:
                logger.error("Fail to write new config file: " + e)
            else:
                logger.debug("Previously created backup was found, checking md5")
                with open(newconffile, "rb") as f:
                    newhash = hashlib.md5(f.read()).hexdigest()
                with open(lastconffile, "rb") as f:
                    oldhash = hashlib.md5(f.read()).hexdigest()
                if newhash == oldhash:
                    os.remove(newconffile)
                    logger.debug("Config was not changed")
                else:
                    logger.info("New config file saved: " + newconffile)
                    os.system(diff_cmd + " " + lastconffile + " " + newconffile + " > " + newconffile + ".diff")
                    logger.debug("Diff saved: " + newconffile + ".diff")



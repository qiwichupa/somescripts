#!/usr/bin/env python3
#
# This is htm-to-xlsx converter for " My Veeam Report"  (https://gist.github.com/smasterson/9136468)
# Usage: ./my_veeam_report_to_xlsx.py veeam-report.htm

import os
import sys
import pandas as pd
import xlsxwriter

infile=os.path.abspath(sys.argv[1])

outfile="{}.xlsx".format(os.path.splitext(infile)[0])
xl=xlsxwriter
if os.path.isfile(outfile):
    print("[Exit] File exists: {}.".format(outfile))
    sys.exit(0)

df = pd.read_html(infile)

writer = pd.ExcelWriter(outfile, engine='xlsxwriter')
workbook  = writer.book
header0_format = workbook.add_format({
    'bold': True})

header_format = workbook.add_format({
    'bold': True,
    'text_wrap': False,
    'valign': 'top',
    'bg_color': '#D7E4BC',
    'border': 1})

row1_format = workbook.add_format({
    'bold': False,
    'text_wrap': False,
    'valign': 'top',
    'bg_color': '#FFFFFF',
    'border': 1,
    'border_color': '#A0A0A0'})

row2_format = workbook.add_format({
    'bold': False,
    'text_wrap': False,
    'valign': 'top',
    'bg_color': '#F5F5F5',
    'border': 1,
    'border_color': '#A0A0A0'})



#df[0].to_excel(writer, sheet_name="Report Info", index = False)
for i in range(1, len(df)-1):
    if df[i].shape[1] == 1 and df[i+1].shape[1] > 1:
        fullname=str(df[i].loc[0][0])
        shortname=fullname[0:30].replace("/"," ")
        try:
            df[i+1].to_excel(writer, sheet_name="{}".format(shortname), startrow=1, index = False, na_rep='')

            # adjust col width
            for column in df[i+1]:
                column_length = max(df[i+1][column].astype(str).map(len).max(), len(column))
                col_idx = df[i+1].columns.get_loc(column)
                writer.sheets[shortname].set_column(col_idx, col_idx, column_length+2)

            # add title
            ws = writer.book.get_worksheet_by_name(shortname)
            ws.write('A1', fullname, header0_format)
            
            # title style
            for col_num, value in enumerate(df[i+1].columns.values):
                ws.write(1, col_num , value, header_format)
            
            # rows style    
            for row_num in range(0, len(df[i+1])):
                for col_num, value in enumerate(df[i+1].values[row_num]):
                    if row_num % 2 == 0:
                        row_format=row1_format
                    else:
                        row_format=row2_format
                    # to avoid empty cell    
                    try:
                        ws.write(row_num+2, col_num , value, row_format)
                    except:
                        ws.write(row_num+2, col_num , '', row_format)
        except:
            pass
    else:
        pass



writer.close()
print("[Save] File: {}.".format(outfile))
sys.exit(0)


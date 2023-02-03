import smtplib
server = smtplib.SMTP('smtp.gmail.com',587)
server.starttls()
server.login('nidheesh0301@gmail.com','XXXX')
server.sendmail('nidheesh0301@gmail.com','nidheesh0301@gmail.com','testing mail from python')
print("Mail Sent..!")
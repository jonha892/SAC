
import smtplib
from email.message import EmailMessage

sender = "repopone"
password = "keyX3rW1z79KRhz4NzAf"
r1 = "jhalstrup@gmail.com"
r2 = "clgdante@outlook.com"

def send_mail(txt):
    msg = EmailMessage()
    msg.set_content(txt)
    msg["Subject"] = "test"
    msg["From"] = sender
    msg["To"] = r1
    msg["Cc"] = r2

    server = smtplib.SMTP("smtp.gmail.com", 587)
    server.ehlo()
    server.starttls()
    server.ehlo()
    server.login(sender, password)
    server.send_message(msg)


send_mail("test")
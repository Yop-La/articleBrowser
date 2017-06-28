library(mailR)
sender <- "alex.guillemine@gmail.com"
recipients <- sender
send.mail(from = sender,
          to = sender,
          subject = "Subject of the email",
          body = "Body of the email",
          smtp = list(host.name = "smtp.gmail.com", port = 587, 
                      user.name = sender,            
                      passwd = "Bgrnht12g!", ssl = TRUE),
          authenticate = TRUE,
          send = TRUE)
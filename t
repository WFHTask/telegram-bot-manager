



docker run -p 8080:8080 --name chatbot -dit `
    -e BOT_TOKEN="8520200276:AAHzpiIjyvfm5JzQnAxJPbhL7Jr11J5GMps" `
    -v ${PWD}/user_configs:/home/user_configs `
    chatgptbot-custom


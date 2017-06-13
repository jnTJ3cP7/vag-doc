FROM base-nodejs:latest

RUN yarn global add @angular/cli@latest
RUN ng set --global packageManager=yarn

# ng serve のデフォルトhost設定
RUN sed -i -e '1a \  "defaults": {' /root/.angular-cli.json \
    && sed -i -e '2a \    "serve": {' /root/.angular-cli.json \
    && sed -i -e '3a \      "host": "0.0.0.0"' /root/.angular-cli.json \
    && sed -i -e '4a \    }' /root/.angular-cli.json \
    && sed -i -e '5a \  },' /root/.angular-cli.json

# ng serve --poll=2000

# EXPOSE 4200
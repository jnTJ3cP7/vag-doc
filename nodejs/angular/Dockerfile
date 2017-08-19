FROM base-nodejs:latest

RUN yarn global add @angular/cli@latest
RUN ng set --global packageManager=yarn

# ng serve のデフォルトhost設定
RUN sed -i -e '1a \  "defaults": {' /root/.angular-cli.json \
    && sed -i -e '2a \    "serve": {' /root/.angular-cli.json \
    && sed -i -e '3a \      "host": "0.0.0.0"' /root/.angular-cli.json \
    && sed -i -e '4a \    }' /root/.angular-cli.json \
    && sed -i -e '5a \  },' /root/.angular-cli.json

WORKDIR /app-base

# ng serve --poll=2000 --disable-host-check

# please command 'vagrant rsync-back' in host machine after 'ng new'


# for normal angular2 (bootstrap angular2 book app)
RUN npm install live-server -g



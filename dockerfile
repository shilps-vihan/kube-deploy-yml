FROM onmv-docker-prod.oneartifactoryprod.verizon.com/nts/onmv/echo-baseimage-pulsar-rasp:v4
USER root

ARG USERNAME
ARG PASSWORD
RUN python3 --version
RUN python3 -m pip --version
RUN python3 -m pip install pip==21.3.1
RUN python3 -m pip install setuptools==59.6.0
#RUN python3 -m pip uninstall pip==9.0.3 --ignored-installed -y
RUN rm -rf /usr/lib/python3.6/site-packages/pip-9.0.3.dist-info

WORKDIR /app
COPY . /app
ENV PORT=5000
RUN curl -u $USERNAME:$PASSWORD -X GET https://oneartifactoryci.verizon.com/artifactory/onmv-docker-prod/nts/onmv/rasp/protect-mode-config/RASPModConf-NodeJS.json --create-dirs -o /opt/rasp/RASPModConf.json
RUN curl -u $USERNAME:$PASSWORD -X GET https://oneartifactoryprod.verizon.com/artifactory/onmv-docker-prod/nts/onmv/rasp/plugin-node-x86_64-linux-centos6-gnu.tgz -o /opt/rasp/nodejs-centos6_gnu.tgz

RUN npm config set registry https://oneartifactoryci.verizon.com/artifactory/api/npm/npm-virtual/
RUN npm cache verify
RUN npm i --legacy-peer-deps
RUN npm i --save echo-vmb-pulsarclient@1.3.8 --legacy-peer-deps
RUN npm i /opt/rasp/nodejs-centos6_gnu.tgz --legacy-peer-deps
RUN rm -rf ./node_modules/i/test
RUN npm run-script build
RUN npm uninstall nodemon eslint lint-staged jest ts-jest --legacy-peer-deps
RUN rm -rf /usr/lib/node_modules/npm
RUN rm -rf ./node_modules/y18n
RUN rm -rf ./node_modules/jsdom/node_modules/ws
RUN rm -rf ./node_modules/node-notifier/notifiers
RUN find ./ -name *.pem 
USER node
EXPOSE 5000
#CMD ["node", "--max-http-header-size=16384", "./build/src/main.js" ]
CMD ["node", "-r", "rasp_agent", "--max-http-header-size=16384", "./build/src/main.js", "--rasp_config=/opt/rasp/RASPModConf.json" ]

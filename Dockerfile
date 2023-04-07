#FROM node:18.7.0-buster-slim as base
FROM node:lts-alpine3.17 as base
ENV HOME /usr/src/app
USER root
WORKDIR $HOME

COPY ["src/package.json", "src/package-lock.json", "$HOME/"]
RUN npm install --frozen-lockfile

COPY ["./src", "$HOME/"]

FROM base as lint
RUN npm run lint

FROM base as test
USER root
RUN apk add chromium
ENV CHROME_BIN=/usr/bin/chromium-browser
RUN npm run test

FROM base as build
RUN npm run build-storybook

FROM nginx:1.22-bullseye
WORKDIR /usr/share/nginx/html
RUN sed -i -e '/^types {/,/^}/{/^}/i\application/javascript  mjs;' -e '}' /etc/nginx/mime.types
COPY --from=build /usr/src/app/storybook-static .
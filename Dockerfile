# To reduce the image size we use a multi-stage build approach, see https://bit.ly/3vMZjNu.
### First stage ###
FROM node:lts AS builder

RUN apt-get install -y curl openssl

WORKDIR /app

COPY ./yarn.lock ./package.json ./

COPY . .

RUN yarn install --frozen-lockfile

RUN yarn prisma generate
RUN yarn build

RUN npm prune --production

####################

### Second stage ###
FROM alpine:3.14.0

RUN apk add --update nodejs

RUN addgroup -S node && adduser -S node -G node

USER node

WORKDIR /home/node/app

COPY --from=builder --chown=node:node /app ./

EXPOSE 3000

CMD ["node", "dist/main.js"]

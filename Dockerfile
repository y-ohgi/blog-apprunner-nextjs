FROM node:16-buster-slim

WORKDIR /app

COPY package.json package-lock.json /app/

RUN npm install

COPY . .

RUN npm run build

EXPOSE 3000

CMD ["npm", "run", "start"]

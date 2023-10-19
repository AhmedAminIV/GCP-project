FROM node:14 AS build

# Create and set the working directory
WORKDIR /app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install app dependencies
RUN npm i

# Copy your application code into the container
COPY . .

FROM gcr.io/distroless/nodejs:14

COPY --from=build /app /app

WORKDIR /app

# Start your Node.js application
CMD ["index.js"]

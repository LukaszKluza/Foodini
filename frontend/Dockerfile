FROM instrumentisto/flutter:latest AS build

WORKDIR /app
COPY . .
RUN flutter pub get
RUN flutter build web

FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
CMD ["nginx", "-g", "daemon off;"]

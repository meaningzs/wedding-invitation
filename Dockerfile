# ---------- 1단계: 정적 파일 빌드 ----------
FROM node:22-alpine AS build
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .

# Vite 환경변수는 "빌드 시점"에 번들에 포함됩니다.
# 비밀값은 이미지/저장소에 넣지 말고 --build-arg 로 주입하세요.
ARG VITE_NAVER_MAP_CLIENT_ID=""
ARG VITE_KAKAO_SDK_JS_KEY=""
ARG VITE_SERVER_URL=""
ARG VITE_STATIC_ONLY="true"
# 서비스 경로 (기본 "/"). GitHub Pages 처럼 하위 경로라면 "/wedding-invitation/" 등으로 지정
ARG BASE_PATH="/"
ENV VITE_NAVER_MAP_CLIENT_ID=$VITE_NAVER_MAP_CLIENT_ID \
    VITE_KAKAO_SDK_JS_KEY=$VITE_KAKAO_SDK_JS_KEY \
    VITE_SERVER_URL=$VITE_SERVER_URL \
    VITE_STATIC_ONLY=$VITE_STATIC_ONLY

RUN npm run build -- --base="$BASE_PATH"

# ---------- 2단계: nginx 로 서빙 ----------
FROM nginx:1.27-alpine
ARG BASE_PATH="/"
COPY deploy/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build /usr/share/nginx/html${BASE_PATH}

EXPOSE 80
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1/healthz >/dev/null || exit 1

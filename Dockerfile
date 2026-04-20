# Stage 1: Install dependencies and Build
FROM node:20-slim AS builder

# Pasang pnpm karena project ini menggunakannya
RUN npm install -g pnpm

WORKDIR /app

# Salin file konfigurasi package
COPY package.json pnpm-lock.yaml* ./

# Install semua dependencies (termasuk devDependencies untuk build)
RUN pnpm install --no-frozen-lockfile

# Salin seluruh kode sumber
COPY . .

# Build aplikasi (menghasilkan folder build/ atau dist/)
RUN pnpm run build

# Stage 2: Production Environment
FROM node:20-slim

RUN npm install -g pnpm
WORKDIR /app

# Salin hasil build dan file yang diperlukan saja dari stage builder
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/build ./build
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json

# Expose port yang digunakan Bolt (default 5173 atau sesuai setting)
EXPOSE 5173

# Jalankan aplikasi dalam mode produksi
# Catatan: Sesuaikan script 'start' di package.json Anda jika perlu
CMD ["pnpm", "run", "start"]

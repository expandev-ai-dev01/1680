# AutoClean Frontend

A React application for identifying and removing temporary or duplicate files.

## Tech Stack

- React 19.2.0
- TypeScript 5.6.3
- Vite 5.4.11
- TailwindCSS 3.4.14
- React Router 7.9.3
- TanStack Query 5.90.2
- Axios 1.12.2

## Getting Started

### Prerequisites

- Node.js 18+ and npm

### Installation

```bash
npm install
```

### Environment Setup

Copy `.env.example` to `.env` and configure:

```bash
cp .env.example .env
```

### Development

```bash
npm run dev
```

Open [http://localhost:5173](http://localhost:5173)

### Build

```bash
npm run build
```

### Preview Production Build

```bash
npm run preview
```

## Project Structure

```
src/
├── app/                 # Application configuration
│   ├── App.tsx         # Root component
│   ├── providers.tsx   # Global providers
│   └── router.tsx      # Routing configuration
├── pages/              # Page components
│   ├── layouts/        # Layout components
│   ├── Home/          # Home page
│   └── NotFound/      # 404 page
├── core/              # Core utilities and components
│   ├── components/    # Shared components
│   ├── lib/          # Library configurations
│   ├── types/        # Global types
│   └── utils/        # Utility functions
├── domain/           # Business domains (to be added)
└── assets/           # Static assets
    └── styles/       # Global styles
```

## Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build
- `npm run lint` - Run ESLint

## API Configuration

The application uses REST API with two contexts:

- **External (Public)**: `/api/v1/external/...`
- **Internal (Authenticated)**: `/api/v1/internal/...`

Configure API URL in `.env`:

```
VITE_API_URL=http://localhost:3000
VITE_API_VERSION=v1
VITE_API_TIMEOUT=30000
```
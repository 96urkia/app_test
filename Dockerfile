FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Inserta el <link rel="manifest"> (y el icono/theme-color) directamente en el
# index.html que Streamlit sirve, para que esté en el HTML inicial y no
# dependa de JavaScript. Así lo detectan tanto PWABuilder como el navegador.
RUN STREAMLIT_STATIC_DIR="$(python -c "import streamlit, os; print(os.path.join(os.path.dirname(streamlit.__file__), 'static'))")" && \
    sed -i "s|</head>|<link rel=\"manifest\" href=\"/app/static/manifest.json\">\n<link rel=\"icon\" href=\"/app/static/icon-192.png\">\n<meta name=\"theme-color\" content=\"#ff4b4b\">\n</head>|" "$STREAMLIT_STATIC_DIR/index.html" && \
    grep -o 'rel="manifest"[^>]*' "$STREAMLIT_STATIC_DIR/index.html"

COPY . .

# Cloud Run inyecta la variable PORT (por defecto 8080) y espera que
# el contenedor escuche en 0.0.0.0
ENV PORT=8080
EXPOSE 8080

CMD streamlit run app.py \
    --server.port=$PORT \
    --server.address=0.0.0.0 \
    --server.headless=true \
    --browser.gatherUsageStats=false

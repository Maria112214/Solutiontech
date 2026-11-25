import json
import os
from urllib.request import Request, urlopen


def explicar(pergunta, resultado):
    modelo = os.getenv("OLLAMA_MODELO", "qwen2.5:1.5b").strip() or "qwen2.5:1.5b"
    corpo = {
        "model": modelo,
        "stream": False,
        "keep_alive": "30m",
        "options": {"temperature": 0, "num_predict": 160},
        "messages": [
            {
                "role": "system",
                "content": (
                    "Explique o resultado em português em até duas frases. "
                    "Use somente os dados recebidos. Não invente números "
                    "nem atribua causas."
                ),
            },
            {
                "role": "user",
                "content": json.dumps(
                    {"pergunta": pergunta, "resultado": resultado},
                    ensure_ascii=False,
                ),
            },
        ],
    }
    pedido = Request(
        "http://127.0.0.1:11434/api/chat",
        data=json.dumps(corpo).encode("utf-8"),
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    with urlopen(pedido, timeout=90) as resposta:
        texto = json.load(resposta)["message"]["content"]
        if not isinstance(texto, str) or not texto.strip():
            raise ValueError("O modelo não devolveu uma explicação.")
        return texto.strip()
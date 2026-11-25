const API_CHAT = "http://127.0.0.1:8000";

const form = document.querySelector("#chat-form");
const campoTexto = document.querySelector("#chat-pergunta");
const botaoEnviar = document.querySelector("#chat-enviar");
const botaoLimpar = document.querySelector("#chat-limpar");
const areaMensagens = document.querySelector("#chat-mensagens");
const areaSugestoes = document.querySelector("#chat-sugestoes");

function horaAtual() {
  return new Date().toLocaleTimeString("pt-BR", {
    hour: "2-digit",
    minute: "2-digit",
  });
}

function rolarParaFinal() {
  areaMensagens.scrollTop = areaMensagens.scrollHeight;
}

function formatarResultado(dados) {
  if (Array.isArray(dados)) {
    if (!dados.length) return ["Nenhum registro encontrado no período."];

    return dados.map((item) => {
      if ("tipo_solicitacao" in item) {
        return `${item.tipo_solicitacao}: ${item.total_solicitacoes} solicitações (${item.atendidas} atendidas · média ${item.tempo_medio_min} min)`;
      }
      if ("status_solicitacao" in item) {
        return `${item.status_solicitacao}: ${item.total_solicitacoes} solicitações`;
      }
      if ("data" in item && "total_compras" in item) {
        return `${item.data}: ${item.total_compras} solicitações registradas`;
      }
      if ("data" in item && "faturamento" in item) {
        return `${item.data}: ${item.faturamento} atendimentos concluídos`;
      }
      return JSON.stringify(item);
    });
  }

  const linhas = [];
  if ("total_solicitacoes" in dados) linhas.push(`Total de solicitações: ${dados.total_solicitacoes}`);
  if ("total_totens" in dados) linhas.push(`Totens ativos: ${dados.total_totens}`);
  if ("total_locais_atendimento" in dados) linhas.push(`Locais de atendimento: ${dados.total_locais_atendimento}`);
  if ("tipos_solicitacao" in dados) linhas.push(`Categorias de ajuda: ${dados.tipos_solicitacao}`);
  if ("solicitacoes_atendidas" in dados) linhas.push(`Atendidas: ${dados.solicitacoes_atendidas}`);
  if ("solicitacoes_encaminhadas" in dados) linhas.push(`Encaminhadas: ${dados.solicitacoes_encaminhadas}`);
  if ("solicitacoes_nao_atendidas" in dados) linhas.push(`Não atendidas: ${dados.solicitacoes_nao_atendidas}`);
  if ("solicitacoes_canceladas" in dados) linhas.push(`Canceladas: ${dados.solicitacoes_canceladas}`);
  if ("distancia_media_km" in dados) linhas.push(`Distância média: ${dados.distancia_media_km} km`);
  if ("tempo_medio_atendimento_min" in dados) linhas.push(`Tempo médio até atendimento: ${dados.tempo_medio_atendimento_min} min`);
  if ("data_inicial" in dados && "data_final" in dados) linhas.push(`Período analisado: ${dados.data_inicial} a ${dados.data_final}`);

  return linhas.length ? linhas : ["Consulta concluída com sucesso."];
}

function adicionarBoasVindas() {
  const linha = document.createElement("div");
  linha.className = "msg-linha msg-bot";
  linha.innerHTML = `
    <div class="msg-avatar bot"><i class="fa-solid fa-robot"></i></div>
    <div class="msg-balao">
      <p class="msg-texto">
        Olá! Pode escrever <strong>qualquer pergunta ou mensagem</strong> na barra abaixo para conversar comigo, 
        ou clicar nos atalhos rápidos para consultar os números exatos do <code>dados.csv</code>.
      </p>
      <span class="msg-hora">${horaAtual()}</span>
    </div>
  `;
  areaMensagens.append(linha);
  rolarParaFinal();
}

function adicionarMensagemUsuario(texto) {
  const linha = document.createElement("div");
  linha.className = "msg-linha msg-usuario";

  const balao = document.createElement("div");
  balao.className = "msg-balao";

  const p = document.createElement("p");
  p.className = "msg-texto";
  p.textContent = texto;

  const hora = document.createElement("span");
  hora.className = "msg-hora";
  hora.textContent = horaAtual();

  balao.append(p, hora);

  const avatar = document.createElement("div");
  avatar.className = "msg-avatar user";
  avatar.innerHTML = '<i class="fa-solid fa-user"></i>';

  linha.append(balao, avatar);
  areaMensagens.append(linha);
  rolarParaFinal();
}

function adicionarDigitando() {
  const linha = document.createElement("div");
  linha.className = "msg-linha msg-bot";
  linha.id = "indicador-digitando";
  linha.innerHTML = `
    <div class="msg-avatar bot"><i class="fa-solid fa-robot"></i></div>
    <div class="msg-balao digitando-balao">
      <div class="digitando-dots">
        <span></span><span></span><span></span>
      </div>
      <span class="digitando-texto">Pensando…</span>
    </div>
  `;
  areaMensagens.append(linha);
  rolarParaFinal();
  return linha;
}

function adicionarRespostaBot(dados) {
  const linha = document.createElement("div");
  linha.className = "msg-linha msg-bot";

  const avatar = document.createElement("div");
  avatar.className = "msg-avatar bot";
  avatar.innerHTML = '<i class="fa-solid fa-robot"></i>';

  const balao = document.createElement("div");
  balao.className = "msg-balao";

  // 1. Resposta conversacional da IA
  if (dados.explicacao) {
    const exp = document.createElement("p");
    exp.className = dados.resultado !== null ? "msg-texto msg-explicacao-ia" : "msg-texto";
    exp.textContent = dados.explicacao;
    balao.append(exp);
  }

  // 2. Cartão de dados do CSV (aparece apenas se a pergunta consultou a planilha)
  if (dados.resultado !== null) {
    const caixaDados = document.createElement("div");
    caixaDados.className = "msg-dados-box";

    const tituloDados = document.createElement("div");
    tituloDados.className = "msg-dados-titulo";
    tituloDados.innerHTML = '<i class="fa-solid fa-database"></i> Dados calculados do CSV';

    const lista = document.createElement("ul");
    lista.className = "msg-dados-lista";
    for (const itemTexto of formatarResultado(dados.resultado)) {
      const li = document.createElement("li");
      li.textContent = itemTexto;
      lista.append(li);
    }

    caixaDados.append(tituloDados, lista);
    balao.append(caixaDados);
  }

  // 3. Aviso caso a chave do Ollama Cloud ainda não esteja configurada
  if (dados.aviso) {
    const avisoBox = document.createElement("div");
    avisoBox.className = "msg-aviso-pill";
    avisoBox.innerHTML = `<i class="fa-solid fa-circle-info"></i> <span></span>`;
    avisoBox.querySelector("span").textContent = dados.aviso;
    balao.append(avisoBox);
  }

  const hora = document.createElement("span");
  hora.className = "msg-hora";
  hora.textContent = horaAtual();
  balao.append(hora);

  linha.append(avatar, balao);
  areaMensagens.append(linha);
  rolarParaFinal();
}

function adicionarErroBot(mensagem) {
  const linha = document.createElement("div");
  linha.className = "msg-linha msg-bot";
  linha.innerHTML = `
    <div class="msg-avatar bot"><i class="fa-solid fa-triangle-exclamation"></i></div>
    <div class="msg-balao">
      <p class="msg-texto">${mensagem}</p>
      <span class="msg-hora">${horaAtual()}</span>
    </div>
  `;
  areaMensagens.append(linha);
  rolarParaFinal();
}

async function enviarPergunta(texto) {
  const pergunta = texto.trim();
  if (!pergunta || botaoEnviar.disabled) return;

  adicionarMensagemUsuario(pergunta);
  campoTexto.value = "";
  botaoEnviar.disabled = true;
  campoTexto.disabled = true;

  const digitando = adicionarDigitando();

  try {
    const retorno = await fetch(API_CHAT + "/chat", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ pergunta }),
    });

    digitando.remove();

    if (!retorno.ok) throw new Error("HTTP " + retorno.status);
    const dados = await retorno.json();
    adicionarRespostaBot(dados);
  } catch {
    digitando.remove();
    adicionarErroBot("Não foi possível conectar ao servidor. Verifique se o backend está rodando na porta 8000.");
  } finally {
    campoTexto.disabled = false;
    botaoEnviar.disabled = false;
    campoTexto.focus();
  }
}

async function carregarSugestoes() {
  adicionarBoasVindas();
  try {
    const retorno = await fetch(API_CHAT + "/chat/perguntas");
    if (!retorno.ok) return;

    const perguntas = await retorno.json();
    areaSugestoes.replaceChildren();

    for (const pergunta of perguntas) {
      const chip = document.createElement("button");
      chip.type = "button";
      chip.className = "chip-pergunta";
      chip.textContent = pergunta;
      chip.addEventListener("click", () => enviarPergunta(pergunta));
      areaSugestoes.append(chip);
    }
  } catch {
    // Se a API ainda estiver subindo, o campo de texto livre continua disponível
  }
}

form.addEventListener("submit", (evento) => {
  evento.preventDefault();
  enviarPergunta(campoTexto.value);
});

botaoLimpar.addEventListener("click", () => {
  areaMensagens.replaceChildren();
  adicionarBoasVindas();
  campoTexto.focus();
});

carregarSugestoes();
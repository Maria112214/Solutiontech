const API_URL = "http://127.0.0.1:8000";

async function consultarAPI(caminho) {
  const resp = await fetch(API_URL + caminho);
  if (!resp.ok) throw new Error("Erro na rota: " + caminho);
  return await resp.json();
}

async function carregarResumo() {
  const conteiner = document.querySelector("#conteudo-resumo");
  try {
    const [resumo, tipos] = await Promise.all([
      consultarAPI("/analise/resumo"),
      consultarAPI("/analise/tipos")
    ]);

    // Preenchimento dos KPIs
    document.querySelector("#total-compras").textContent = Number(resumo.total_solicitacoes || resumo.total_compras || 0).toLocaleString("pt-BR");
    document.querySelector("#total-clientes").textContent = Number(resumo.total_totens || resumo.total_clientes || 0).toLocaleString("pt-BR");
    
    let tiposLista = [];
    if (Array.isArray(tipos)) {
      tiposLista = tipos;
    } else if (tipos && typeof tipos === "object") {
      tiposLista = tipos.por_tipo || tipos.tipos || tipos.por_forma_pagamento || tipos.dados || [];
    }

    document.querySelector("#total-produtos").textContent = resumo.total_tipos || resumo.total_produtos || tiposLista.length || 0;

    if (tiposLista.length === 0) {
      conteiner.innerHTML = `<p style="color: var(--texto-secundario); text-align: center; padding: 1.5rem;">Nenhum dado encontrado.</p>`;
      return;
    }

    // Tabela estilizada
    let html = `
      <table style="width: 100%; border-collapse: collapse; text-align: left; font-size: 0.95rem;">
        <thead>
          <tr style="border-bottom: 1px solid var(--borda-suave); color: var(--texto-secundario);">
            <th style="padding: 1rem;">Categoria / Tipo de Ajuda</th>
            <th style="padding: 1rem; text-align: right;">Total de Solicitações</th>
          </tr>
        </thead>
        <tbody>
    `;

    tiposLista.forEach(item => {
      const nome = item.tipo || item.tipo_ajuda || item.forma_pagamento || item.nome || item.label || Object.values(item)[0] || "Outros";
      const qtd = item.total_solicitacoes || item.total_compras || item.total || item.quantidade || item.qtd || Object.values(item)[1] || 0;

      html += `
        <tr style="border-bottom: 1px solid rgba(255, 255, 255, 0.04);">
          <td style="padding: 1rem; font-weight: 500;">
            <i class="fa-solid fa-angle-right" style="color: var(--cor-azul); margin-right: 0.75rem;"></i>${nome}
          </td>
          <td style="padding: 1rem; text-align: right; font-weight: 700; color: #60a5fa;">
            ${Number(qtd).toLocaleString("pt-BR")}
          </td>
        </tr>
      `;
    });

    html += `</tbody></table>`;
    conteiner.innerHTML = html;

  } catch (erro) {
    if (conteiner) {
      conteiner.innerHTML = `<p style="color: #ef4444; text-align: center; padding: 1.5rem;"><i class="fa-solid fa-circle-exclamation"></i> Falha ao carregar dados: ${erro.message}</p>`;
    }
  }
}

const botao = document.querySelector("#botao-atualizar");
if (botao) botao.addEventListener("click", carregarResumo);
carregarResumo();
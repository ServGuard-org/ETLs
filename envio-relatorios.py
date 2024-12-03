from dotenv import load_dotenv
from slack_sdk import WebClient
from slack_sdk.errors import SlackApiError
import os

load_dotenv()

# Função para enviar arquivo ao Slack
def enviar_para_slack(canal, caminho_arquivo, mensagem):
    client = WebClient(token=os.getenv("TOKEN_SLACK"))

    try:
        response = client.files_upload_v2(
            channels=canal,
            initial_comment=mensagem,
            file=caminho_arquivo
        )
        print("Arquivo enviado para o Slack com sucesso!")
    except SlackApiError as e:
        print(f"Erro ao enviar para o Slack: {e.response['error']}")

# Função principal
def main():

    opcao = None
    condicao = True
    while condicao:
        opcao = input("\033[1mDigite 1 para \033[31mRelatório Semanal\033[m ou 2 para \033[34mRelatório Mensal\033[m: ")
        if opcao.isdigit():
            opcao = int(opcao)
            if opcao == 1 or opcao == 2:
                condicao = False

    caminho_relatorio_html = None
    caminho_relatorio_pdf = None
    mensagem = None
    if opcao == 1:
        caminho_relatorio_html = "./relatorio_semanal.html"
        caminho_relatorio_pdf = "./relatorio_semanal.pdf"
        mensagem = "Relatório Semanal de Monitoramento de Hardware: "
    elif opcao == 2:
        caminho_relatorio_html = "./relatorio_mensal.html"
        caminho_relatorio_pdf = "./relatorio_mensal.pdf"
        mensagem = "Relatório Mensal de Monitoramento de Hardware: "

    channel_id = "C081XHLS15M"

    enviar_para_slack(channel_id, caminho_relatorio_html, mensagem)
    enviar_para_slack(channel_id, caminho_relatorio_pdf, mensagem)

if __name__ == "__main__":
    main()

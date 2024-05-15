import 'package:Satsails/providers/settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static final _t = Translations.byText('en_us') +
      {
        'en_us': 'View Accounts',
        'pt_br': 'Ver Contas',
      } +
      {
        'en_us': 'Total balance',
        'pt_br': 'Saldo total',
      } +
      {
        'en_us': 'Or',
        'pt_br': 'Ou',
      } +
      {
        'en_us': 'Sail your wealth to the cloud',
        'pt_br': 'Navegue sua riqueza para a nuvem',
      } +
      {
        'en_us': 'Register Account',
        'pt_br': 'Registrar Conta',
      } +
      {
        'en_us': 'Recover Account',
        'pt_br': 'Recuperar Conta',
      } +
      {
        'en_us': 'Word',
        'pt_br': 'Palavra',
      } +
      {
        'en_us': 'Set PIN',
        'pt_br': 'Definir PIN',
      } +
      {
        'en_us': 'Please enter a 6 digit PIN',
        'pt_br': 'Por favor, insira um PIN de 6 dígitos',
      } +
      {
        'en_us': 'Invalid PIN',
        'pt_br': 'PIN inválido',
      } +
      {
        'en_us': '12 words',
        'pt_br': '12 palavras',
      } +
      {
        'en_us': '24 words',
        'pt_br': '24 palavras',
      } +
      {
        'en_us': 'Invalid mnemonic',
        'pt_br': 'Mnemônica inválido',
      } +
      {
        'en_us': 'Forgot PIN',
        'pt_br': 'Esqueceu o PIN',
      } +
      {
        'en_us': 'Unlock',
        'pt_br': 'Desbloquear',
      } +
      {
        'en_us': 'Add Money',
        'pt_br': 'Adicionar Dinheiro',
      } + {
    'en_us': 'Exchange',
    'pt_br': 'Corretora',} + {
    'en_us': 'Pay',
    'pt_br': 'Pagar',}
      + {'en_us': "Recieve",
        'pt_br': "Receber",}+
      {
        'en_us': 'Home',
        'pt_br': 'Início',
      } +
      {
        'en_us': 'Analytics',
        'pt_br': 'Análises',
      } +
      {
        'en_us': 'Currency',
        'pt_br': 'Moeda',
      } +
      {
        'en_us': 'Help & Support & Bug reporting',
        'pt_br': 'Ajuda & Suporte & Relatório de bugs',
      } +
      {
        'en_us': 'Chat with us on Telegram!',
        'pt_br': 'Converse conosco no Telegram!',
      } +
      {
        'en_us': 'Claim Lightning Transactions',
        'pt_br': 'Reivindique Transações Lightning',
      } +
      {
        'en_us': 'View See Words',
        'pt_br': 'Ver Palavras',
      } +
      {
        'en_us': 'Write them down and keep them safe!',
        'pt_br': 'Anote-as e mantenha-as seguras!',
      } +
      {
        'en_us': 'Language',
        'pt_br': 'Idioma',
      } +
      {
        'en_us': 'Bitcoin Unidade',
        'pt_br': 'Unidade Bitcoin',
      } +
      {
        'en_us': 'Delete Wallet',
        'pt_br': 'Excluir Carteira',
      } +
      {
        'en_us': 'Claim Receiving',
        'pt_br': 'Reivindicar Recebimento',
      } +
      {
        'en_us': 'Refund Sending',
        'pt_br': 'Envio de Reembolso',
      } +
      {
        'en_us': 'Seed Words',
        'pt_br': 'Palavras Semente',
      } +
      {
        'en_us': 'Portuguese',
        'pt_br': 'Português',
      } +
      {
        'en_us': 'English',
        'pt_br': 'Inglês',
      } +
      {
        'en_us': 'Secure Bitcoin',
        'pt_br': 'Bitcoin Seguro',
      } +
      {
        'en_us': 'Instant Payments',
        'pt_br': 'Pagamentos Instantâneos',
      } +
      {
        'en_us': 'Assets',
        'pt_br': 'Ativos',
      } +
      {
        'en_us': 'Charge Wallet',
        'pt_br': 'Carregar Carteira',
      } +
      {
        'en_us': 'Add Money with Pix',
        'pt_br': 'Adicionar Dinheiro com Pix',
      } +
      {
        'en_us': 'Coming Soon',
        'pt_br': 'Em Breve',
      } +
      {
        'en_us': 'Bitcoin Layer Swap',
        'pt_br': 'Troca de Camada Bitcoin',
      } +
      {
        'en_us': 'Swap',
        'pt_br': 'Trocar',
      } +
      {
        'en_us': 'Balance to Spend:',
        'pt_br': 'Saldo para Gastar:',
      } +
      {
        'en_us': 'Receive',
        'pt_br': 'Receber',
      } +
      {
        'en_us': 'Minimum amount:',
        'pt_br': 'Quantidade mínima:',
      } +
      {
        'en_us': 'Fastest',
        'pt_br': 'Mais rápido',
      } +
      {
        'en_us': 'How fast would you like to receive your bitcoin',
        'pt_br': 'Quão rápido você gostaria de receber seu bitcoin',
      } +
      {
        'en_us': 'Bitcoin Network fee',
        'pt_br': 'Taxa da Rede Bitcoin',
      } +
      {
        'en_us': 'Balance to spend:',
        'pt_br': 'Saldo para gastar:',
      } +
      {
        'en_us': 'Switch',
        'pt_br': 'Alternar',
      } +
      {
        'en_us': 'Paste',
        'pt_br': 'Colar',
      } +
      {
        'en_us': 'Flash',
        'pt_br': 'Flash',
      } +
      {
        'en_us': 'Create Address',
        'pt_br': 'Criar Endereço',
      } +
      {
        'en_us': 'Sent',
        'pt_br': 'Enviado',
      } +
      {
        'en_us': 'Received',
        'pt_br': 'Recebido',
      } +
      {
        'en_us': 'Fee',
        'pt_br': 'Taxa',
      } +
      {
        'en_us': 'Select Range',
        'pt_br': 'Selecionar Intervalo',
      } +
      {
        'en_us': 'All Transactions',
        'pt_br': 'Todas as Transações',
      } +
      {
        'en_us': 'Pull up to refresh',
        'pt_br': 'Puxe para atualizar',
      } +
      {
        'en_us': 'No swaps found',
        'pt_br': 'Nenhuma troca encontrada',
      } +
      {
        'en_us': 'Confirm',
        'pt_br': 'Confirmar',
      } +
      {
        'en_us': 'Are you sure you want to delete the wallet',
        'pt_br': 'Tem certeza de que deseja excluir a carteira',
      } +
      {
        'en_us': 'Cancel',
        'pt_br': 'Cancelar',
      } +
      {
        'en_us': 'Yes',
        'pt_br': 'Sim',
      } +
      {
        'en_us': 'Reset PIN',
        'pt_br': 'Redefinir PIN',
      } +
      {
        'en_us': 'This will delete all your data and reset your PIN',
        'pt_br': 'Isso excluirá todos os seus dados e redefinirá seu PIN',
      } +
      {
        'en_us': 'Do you want to proceed?',
        'pt_br': 'Você quer prosseguir?',
      } +
      {
        'en_us': 'Outgoing',
        'pt_br': 'Saindo',
      } +
      {
        'en_us': 'Incoming',
        'pt_br': 'Entrando',
      } +
      {
        'en_us': 'Swap',
        'pt_br': 'Trocar',
      } +
      {
        'en_us': 'Multiple',
        'pt_br': 'Múltiplo',
      } +
      {
        'en_us': 'Received',
        'pt_br': 'Recebido',
      } +
      {
        'en_us': 'Sent',
        'pt_br': 'Enviado',
      } +
      {
        'en_us': 'Search the blockchain',
        'pt_br': 'Pesquisar a blockchain',
      } +
      {
        'en_us': 'Exception: Invalid Address',
        'pt_br': 'Exceção: Endereço inválido',
      } +
      {
        'en_us': 'Bitcoin Balance',
        'pt_br': 'Saldo Bitcoin',
      } +
      {
        'en_us': 'Transaction In',
        'pt_br': 'Transação em',
      } +
      {
        'en_us': 'Slide to send',
        'pt_br': 'Deslize para enviar',
      } +
      {
        'en_us': 'Insufficient funds',
        'pt_br': 'Fundos insuficientes',
      } +
      {
        'en_us': 'Liquid Balance',
        'pt_br': 'Saldo Líquido',
      } +
      {
        'en_us': 'Reais Balance',
        'pt_br': 'Saldo Reais',
      } +
      {
        'en_us': 'Dollar Balance',
        'pt_br': 'Saldo Dólar',
      } +
      {
        'en_us': 'Euro Balance',
        'pt_br': 'Saldo Euro',
      } +
      {
        'en_us': 'Waiting for transaction...',
        'pt_br': 'Aguardando transação...',
      } +
      {
        'en_us': 'Set an amount to create an invoice',
        'pt_br': 'Defina um valor para criar uma fatura',
      } +
      {
        'en_us': 'Amount is above the maximal limit',
        'pt_br': 'O valor está acima do limite máximo',
      } +
      {
        'en_us': 'Amount is below the minimal limit',
        'pt_br': 'O valor está abaixo do limite mínimo',
      } +
      {
        'en_us': 'Amount',
        'pt_br': 'Quantidade',
      } +
      {
        'en_us': 'Type',
        'pt_br': 'Tipo',
      } +
      {
        'en_us': 'Invoice',
        'pt_br': 'Fatura',
      };

  String i18n(WidgetRef ref) {
    final currentLanguage = ref.read(settingsProvider).language;
    return localize(this, _t, locale: currentLanguage);
  }
}
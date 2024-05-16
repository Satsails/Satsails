import 'package:Satsails/providers/settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static final _t = Translations.byText('en') +
      {
        'en': 'View Accounts',
        'pt': 'Ver Contas',
      } +
      {
        'en': 'Total balance',
        'pt': 'Saldo total',
      } +
      {
        'en': 'or',
        'pt': 'ou',
      } +
      {
        'en': 'Sail your wealth to the cloud',
        'pt': 'Navegue sua riqueza para a nuvem',
      } +
      {
        'en': 'Register Account',
        'pt': 'Registrar Conta',
      } +
      {
        'en': 'Recover Account',
        'pt': 'Recuperar Conta',
      } +
      {
        'en': '       Word %s',
        'pt': '       Palavra %s',
      } +
      {
        'en': 'Set PIN',
        'pt': 'Definir PIN',
      } +
      {
        'en': 'Please enter a 6 digit PIN',
        'pt': 'Por favor, insira um PIN de 6 dígitos',
      } +
      {
        'en': 'Invalid PIN',
        'pt': 'PIN inválido',
      } +
      {
        'en': '12 words',
        'pt': '12 palavras',
      } +
      {
        'en': '24 words',
        'pt': '24 palavras',
      } +
      {
        'en': 'Invalid mnemonic',
        'pt': 'Mnemônica inválido',
      } +
      {
        'en': 'Forgot PIN',
        'pt': 'Esqueceu o PIN',
      } +
      {
        'en': 'Unlock',
        'pt': 'Desbloquear',
      } +
      {
        'en': 'Add Money',
        'pt': 'Adicionar Dinheiro',
      } + {
    'en': 'Exchange',
    'pt': 'Trocar',} + {
    'en': 'Pay',
    'pt': 'Pagar',}
      + {'en': "Recieve",
        'pt': "Receber",}+
      {
        'en': 'Home',
        'pt': 'Início',
      } +
      {
        'en': 'Analytics',
        'pt': 'Análises',
      } +
      {
        'en': 'Currency',
        'pt': 'Moeda',
      } +
      {
        'en': 'Help & Support & Bug reporting',
        'pt': 'Ajuda & Suporte & Relatório de bugs',
      } +
      {
        'en': 'Chat with us on Telegram!',
        'pt': 'Converse conosco no Telegram!',
      } +
      {
        'en': 'Claim Lightning Transactions',
        'pt': 'Reivindique Transações Lightning',
      } +
      {
        'en': 'View Seed Words',
        'pt': 'Ver Palavras chave',
      } +
      {
        'en': 'Write them down and keep them safe!',
        'pt': 'Anote-as e mantenha-as seguras!',
      } +
      {
        'en': 'Language',
        'pt': 'Idioma',
      } +
      {
        'en': 'Bitcoin Unit',
        'pt': 'Unidade Bitcoin',
      } +
      {
        'en': 'Delete Wallet',
        'pt': 'Excluir Carteira',
      } +
      {
        'en': 'Claim Receiving',
        'pt': 'Reivindicar Recebimento',
      } +
      {
        'en': 'Refund Sending',
        'pt': 'Envio de Reembolso',
      } +
      {
        'en': 'Seed Words',
        'pt': 'Palavras Semente',
      } +
      {
        'en': 'Portuguese',
        'pt': 'Português',
      } +
      {
        'en': 'English',
        'pt': 'Inglês',
      } +
      {
        'en': 'Secure Bitcoin',
        'pt': 'Bitcoin Seguro',
      } +
      {
        'en': 'Instant Payments',
        'pt': 'Pagamentos Instantâneos',
      } +
      {
        'en': 'Assets',
        'pt': 'Ativos',
      } +
      {
        'en': 'Charge Wallet',
        'pt': 'Carregar Carteira',
      } +
      {
        'en': 'Add Money with Pix',
        'pt': 'Adicionar Dinheiro com Pix',
      } +
      {
        'en': 'Coming Soon',
        'pt': 'Em Breve',
      } +
      {
        'en': 'Bitcoin Layer Swap',
        'pt': 'Troca de Camada Bitcoin',
      } +
      {
        'en': 'Swap',
        'pt': 'Troca',
      } +
      {
        'en': 'Balance to Spend: ',
        'pt': 'Saldo para Gastar: ',
      } +
      {
        'en': 'Receive',
        'pt': 'Receber',
      } +
      {
        'en': 'Minimum amount:',
        'pt': 'Quantidade mínima:',
      } +
      {
        'en': 'Fastest',
        'pt': 'A Mais rápida possivel',
      } +
      {
        'en': 'How fast would you like to receive your bitcoin',
        'pt': 'Quão rápido você gostaria de receber seu bitcoin',
      } +
      {
        'en': 'Bitcoin Network fee:',
        'pt': 'Taxa da Rede Bitcoin:',
      } +
      {
        'en': 'Switch',
        'pt': 'Alternar',
      } +
      {
        'en': 'Paste',
        'pt': 'Colar',
      } +
      {
        'en': 'Flash',
        'pt': 'Flash',
      } +
      {
        'en': 'Create Address',
        'pt': 'Criar Endereço',
      } +
      {
        'en': 'Sent',
        'pt': 'Enviado',
      } +
      {
        'en': 'Received',
        'pt': 'Recebido',
      } +
      {
        'en': 'Fee',
        'pt': 'Taxa',
      } +
      {
        'en': 'Select Range',
        'pt': 'Selecionar Intervalo',
      } +
      {
        'en': 'All Transactions',
        'pt': 'Todas as Transações',
      } +
      {
        'en': 'Pull up to refresh',
        'pt': 'Puxe para atualizar',
      } +
      {
        'en': 'No swaps found',
        'pt': 'Nenhuma troca encontrada',
      } +
      {
        'en': 'Confirm',
        'pt': 'Confirmar',
      } +
      {
        'en': 'Are you sure you want to delete the wallet',
        'pt': 'Tem certeza de que deseja excluir a carteira',
      } +
      {
        'en': 'Cancel',
        'pt': 'Cancelar',
      } +
      {
        'en': 'Yes',
        'pt': 'Sim',
      } +
      {
        'en': 'Reset PIN',
        'pt': 'Redefinir PIN',
      } +
      {
        'en': 'This will delete all your data and reset your PIN',
        'pt': 'Isso excluirá todos os seus dados e redefinirá seu PIN',
      } +
      {
        'en': 'Do you want to proceed?',
        'pt': 'Você quer prosseguir?',
      } +
      {
        'en': 'Outgoing',
        'pt': 'Saindo',
      } +
      {
        'en': 'Incoming',
        'pt': 'Entrando',
      } +
      {
        'en': 'Swap',
        'pt': 'Trocar',
      } +
      {
        'en': 'Multiple',
        'pt': 'Múltiplas',
      } +
      {
        'en': 'Received',
        'pt': 'Recebido',
      } +
      {
        'en': 'Sent',
        'pt': 'Enviado',
      } +
      {
        'en': 'Search the blockchain',
        'pt': 'Pesquisar a blockchain',
      } +
      {
        'en': 'Exception: Invalid Address',
        'pt': 'Exceção: Endereço inválido',
      } +
      {
        'en': 'Bitcoin Balance',
        'pt': 'Saldo Bitcoin',
      } +
      {
        'en': 'Transaction in ',
        'pt': 'Transação em ',
      } +
      {
        'en': 'Slide to send',
        'pt': 'Deslize para enviar',
      } +
      {
        'en': 'Insufficient funds',
        'pt': 'Fundos insuficientes',
      } +
      {
        'en': 'Liquid Balance',
        'pt': 'Saldo Líquido',
      } +
      {
        'en': 'Reais Balance',
        'pt': 'Saldo Reais',
      } +
      {
        'en': 'Dollar Balance',
        'pt': 'Saldo Dólar',
      } +
      {
        'en': 'Euro Balance',
        'pt': 'Saldo Euro',
      } +
      {
        'en': 'Waiting for transaction...',
        'pt': 'Aguardando transação...',
      } +
      {
        'en': 'Set an amount to create an invoice',
        'pt': 'Defina um valor para criar uma fatura',
      } +
      {
        'en': 'Amount is above the maximal limit',
        'pt': 'O valor está acima do limite máximo',
      } +
      {
        'en': 'Amount is below the minimal limit',
        'pt': 'O valor está abaixo do limite mínimo',
      } +
      {
        'en': 'Amount',
        'pt': 'Quantidade',
      } +
      {
        'en': 'Type',
        'pt': 'Tipo',
      } +
      {
        'en': 'Invoice',
        'pt': 'Fatura',
      } +
      {
        'en': 'Please authenticate to open the app',
        'pt': 'Por favor, autentique-se para abrir o aplicativo'
      } +
      {
        'en': 'You are offline.',
        'pt': 'Você está offline.'
      } +
      {
        'en': 'Amount is below minimum peg out amount',
        'pt': 'O valor está abaixo do valor mínimo'
      } +
      {
        'en': 'Swap done! Check Analytics for more info',
        'pt': 'Troca feita! Verifique Análises para mais informações'
      } +
      {
        'en': 'Sending Transaction fee:',
        'pt': 'Taxa de transação de envio:',
      }+
      {
        'en': 'Value to receive: %s',
        'pt': 'Valor a receber: %s',
      }+
      {
        'en': 'Invalid address',
        'pt': 'Endereço inválido',
      } +
      {
        'en': 'Invalid lightning address',
        'pt': 'Endereço lightning inválido',
      } +
      {
        'en': 'Data cannot be null or empty',
        'pt': 'Os dados não podem ser nulos ou vazios',
      } +
      {
        'en': 'Transaction Sent',
        'pt': 'Transação Enviada',
      }+
      {
        'en': 'Fee:',
        'pt': 'Taxa:',
      } +
      {
        'en': 'Transaction Received',
        'pt': 'Transação Recebida',
      } +
      {
        'en': 'Instant Bitcoin',
        'pt': 'Bitcoin Instantâneo',
      }+
      {
        'en': 'Fiat Swap',
        'pt': 'Troca de Fiat',
      } +
      {
        'en': 'Unconfirmed',
        'pt': 'Não confirmada',
      } +
      {
        'en': 'Confirmed',
        'pt': 'Confirmada',
      } +
      {
        'en': 'Unknown',
        'pt': 'Desconhecida',
      } +
      {
        'en': 'Issuance',
        'pt': 'Emissão',
      } +
      {
        'en': 'Reissuance',
        'pt': 'Reemissão',
      } +
      {
        'en': 'Burn',
        'pt': 'Queimafa',
      } +
      {
        'en': 'Incoming',
        'pt': 'Recebido',
      } +
      {
        'en': 'Outgoing',
        'pt': 'Enviado',
      }+
      {
        'en': 'Settings',
        'pt': 'Configurações',
      } +
      {
        'en': 'Enter PIN',
        'pt': 'Digite o PIN',
      } +
      {
        'en': 'Swaps',
        'pt': 'Trocas',
      } +
      {
        'en': 'PIN must be exactly 6 digits',
        'pt': 'O PIN deve ter exatamente 6 dígitos',
      } +
      {
        'en': 'Insufficient funds',
        'pt': 'Fundos insuficientes',
      }+    {
    'en': 'Order ID',
    'pt': 'ID do Pedido',
  } +
      {
        'en': 'Received at',
        'pt': 'Recebido em',
      } +
      {
        'en': 'Send Transaction',
        'pt': 'Transação de Enviada',
      } +
      {
        'en': 'Received Transaction',
        'pt': 'Transação Recebida',
      } +
      {
        'en': 'Amount sent',
        'pt': 'Quantidade enviada',
      } +
      {
        'en': 'Amount received',
        'pt': 'Quantidade recebida',
      } +
      {
        'en': 'Status',
        'pt': 'Status',
      } +
      {
        'en': 'Insufficient Amount',
        'pt': 'Quantidade Insuficiente',
      } +
      {
        'en': 'Confirmations',
        'pt': 'Confirmações',
      } +
      {
        'en': 'Detected',
        'pt': 'Detectada',
      } +
      {
        'en': 'Needed',
        'pt': 'Necessárias',
      } +
      {
        'en': 'Processing',
        'pt': 'Processando',
      } +
      {
        'en': 'Done',
        'pt': 'Concluído',
      } +
      {
        'en': 'Unknown',
        'pt': 'Desconhecido',
      } +
      {
        'en': 'Error',
        'pt': 'Erro',
      } +
      {
        'en': 'No Information',
        'pt': 'Sem Informação',
      } +
      {
        'en': 'No transactions found. Check back later.',
        'pt': 'Nenhuma transação encontrada. Verifique novamente mais tarde.',
      }+
      {
        'en': 'Account Management',
        'pt': 'Gerenciamento de Contas',
      } + {
    'en': 'Confirm Payment',
    'pt': 'Confirmar Pagamento',
  } + {
    'en': 'Details',
    'pt': 'Detalhes',
  } +    {
    'en': '10 minutes',
    'pt': '10 minutos',
  } +
      {
        'en': '30 minutes',
        'pt': '30 minutos',
      } +
      {
        'en': '1 hour',
        'pt': '1 hora',
      } +
      {
        'en': 'Days',
        'pt': 'Dias',
      } +
      {
        'en': 'Weeks',
        'pt': 'Semanas',
      } +
      {
        'en': 'Invalid number of blocks.',
        'pt': 'Número inválido de blocos.',
      } +
      {
        'en': 'Invalid number of blocks.',
        'pt': 'Número inválido de blocos.',
      } +
      {
        'en': 'Insufficient funds for a transaction this fast',
        'pt': 'Fundos insuficientes para uma transação tão rápida',
      } +
      {
        'en': 'Amount is too small',
        'pt': 'O valor é muito pequeno',
      } +
      {
        'en': 'Deleted',
        'pt': 'Excluído',
      } +
      {
        'en': 'Delete',
        'pt': 'Excluir',
      } +
      {
        'en': 'Claimed',
        'pt': 'Reivindicado',
      } +
      {
        'en': 'Claim',
        'pt': 'Reivindicar',
      } +
      {
        'en': 'Amount',
        'pt': 'Quantidade',
      } +
      {
        'en': 'Claim lightning transactions',
        'pt': 'Reivindicar transações lightning',
      } +
      {
        'en': 'Set an amount to create an invoice',
        'pt': 'Defina um valor para criar uma fatura',
      } +
      {
        'en': 'Amount is below the minimal limit',
        'pt': 'O valor está abaixo do limite mínimo',
      } +
      {
        'en': 'Amount is above the maximal limit',
        'pt': 'O valor está acima do limite máximo',
      } +
      {
        'en': 'Error creating swap',
        'pt': 'Erro ao criar troca',
      } +
      {
        'en': 'Could not claim transaction',
        'pt': 'Não foi possível reivindicar a transação',
      } +
      {
        'en': 'Current Balance',
        'pt': 'Saldo Atual',
      } +
      {
        'en': 'Add money with Euro',
        'pt': 'Adicionar dinheiro com Euro',
      };





  String i18n(WidgetRef ref) {
    var currentLanguage = ref.read(settingsProvider).language;
    if (currentLanguage == 'EN' || currentLanguage == 'en') {
      currentLanguage = 'en';
    } else if (currentLanguage == 'PT' || currentLanguage == 'pt') {
      currentLanguage = 'pt';
    }
    return localize(this, _t, locale: currentLanguage);
  }
}
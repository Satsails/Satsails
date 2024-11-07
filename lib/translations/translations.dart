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
        'pt': 'Comprar',
      } +
      {
        'en': 'Exchange',
        'pt': 'Converter',} +
      {
        'en': 'Pay',
        'pt': 'Pagar',} +
      {'en': "Recieve",
        'pt': "Receber",} +
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
        'en': 'Lightning Transactions',
        'pt': 'Transações Lightning',
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
        'en': 'Receiving',
        'pt': 'Recebimento',
      } +
      {
        'en': 'Sending',
        'pt': 'Envios',
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
        'en': 'Fiat Swap',
        'pt': 'Troca de Fiat',
      }+
      {
        'en': 'Multiple',
        'pt': 'Múltiplas',
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
        'en': 'Liquid Balance',
        'pt': 'Saldo Liquid',
      } +
      {
        'en': 'Depix Balance',
        'pt': 'Saldo Depix',
      } +
      {
        'en': 'USDt Balance',
        'pt': 'Saldo Dólar',
      } +
      {
        'en': 'EURx Balance',
        'pt': 'Saldo EURx',
      } +
      {
        'en': 'Waiting for transaction...',
        'pt': 'Aguardando transação...',
      } +
      {
        'en': 'Set an amount to create a lightning invoice',
        'pt': 'Defina um valor para criar uma fatura lightning',
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
        'en': 'Swap done!',
        'pt': 'Troca feita!'
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
        'pt': 'Conversões'
      } +
      {
        'en': 'PIN must be exactly 6 digits',
        'pt': 'O PIN deve ter exatamente 6 dígitos',
      } +
      {
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
      } +
      {
        'en': 'Confirm Payment',
        'pt': 'Confirmar Pagamento',
      } +
      {
        'en': 'Details',
        'pt': 'Detalhes',
      } +
      {
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
        'en': 'Set an amount to create a lightning invoice',
        'pt': 'Defina um valor para criar uma fatura lightning',
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
        'en': 'Add money with EURx',
        'pt': 'Adicionar dinheiro com EURx',
      } +
      {
        'en': 'Cannot exchange 0 amount',
        'pt': 'Não é possível trocar 0 quantidade',
      } +
      {
        'en': 'Invalid address, only Bitcoin, Liquid and lightning invoices are supported.',
        'pt': 'Endereço inválido, apenas enderecos Bitcoin, Liquid e lightning são suportados.',
      } +
      {
        'en': 'Address copied to clipboard',
        'pt': 'Endereço copiado para a área de transferência',
      } +
      {
        'en': 'Please enter a PIN',
        'pt': 'Por favor, insira um PIN',
      } +
      {
        'en': 'Refund',
        'pt': 'Reembolso',
      } +
      {
        'en': 'Could not refund transaction',
        'pt': 'Não foi possível reembolsar a transação',
      } +
      {
        'en': 'Could not claim transaction',
        'pt': 'Não foi possível reivindicar a transação',
      } +
      {
        'en': 'Could not claim transaction',
        'pt': 'Não foi possível reivindicar a transação',
      }+
      {
        'en': 'Confirm lightning payment',
        'pt': 'Confirmar pagamento lightning',
      }+
      {
        'en': 'Beta software, use at your own risk',
        'pt': 'Software beta, use por sua conta e risco',
      }+
      {
        'en': 'Opt out of the system',
        'pt': 'Opte por sair do sistema',
      }+
      {
        'en': 'Your wallet is empty',
        'pt': 'Sua carteira está vazia',
      }+
      {
        'en': 'Request camera permission',
        'pt': 'Solicitar permissão da câmera',
      }+
      {
        'en': 'Complete lightning transactions',
        'pt': 'Completar transações lightning',
      }+
      {
        'en': 'No transactions',
        'pt': "Sem transações",
      }+
      {
        'en': 'Pay to complete',
        'pt': "Pague para completar",
      }+
      {
        'en': 'Amount is too small',
        'pt': "O valor é muito pequeno",
      }+
      {
        'en': 'Search the blockchain',
        'pt': "Pesquisar na blockchain",
      }+
      {
        'en': 'Show Balance',
        'pt': "Mostrar Saldo",
      }+
      {
        'en': 'Show Statistics over period',
        'pt': "Mostrar Estatísticas ao longo do período",
      }+
      {
        'en': '1w',
        'pt': "1s",
      }+
      {
        'en': 'Custom',
        'pt': "Escolher",
      }+
      {
        'en': 'Spending',
        'pt': "Gastos",
      }+
      {
        'en': 'Income',
        'pt': 'Entradas'
      }+
      {
        'en': 'Show balance over period',
        'pt': 'Mostrar saldo ao longo do período'
      }+
      {
        'en': 'words',
        'pt': 'palavras'
      }+
      {
        'en': 'Word',
        'pt': 'Palavra'
      }+
      {
        'en': 'Backup your wallet',
        'pt': 'Faça backup de sua carteira'
      }+
      {
        'en': 'Backup Wallet',
        'pt': 'Backup da Carteira'
      }+
      {
        'en': 'Seed Words',
        'pt': 'Seed'
      }+
      {
        'en': 'Select the correct word for each position:',
        'pt': 'Selecione a palavra correta para cada posição:'
      }+
      {
        'en': 'Word in position',
        'pt': 'Palavra na posição'
      }+
      {
        'en': 'Verify',
        'pt': 'Verificar'
      }+
      {
        'en': 'Wallet successfully backed up!',
        'pt': 'Carteira guardada com sucesso!'
      }+
      {
        'en': 'Incorrect selections. Please try again.',
        'pt': 'Seleções incorretas. Por favor, tente novamente.'
      }+
      {
        'en': 'Balance',
        'pt': 'Saldo'
      }+
      {
        'en': 'Insufficient funds, or not enough liquid bitcoin to pay fees.',
        'pt': 'Fundos insuficientes, ou não há liquid bitcoin suficiente para pagar as taxas.'
      }+
      {
        'en': 'Version: Forward Unto Dawn',
        'pt': 'Versão: Avante até o Amanhecer'
      }+
      {
        'en': 'Receive in',
        'pt': 'Receber em'
      }+
      {
        'en': 'Claim transaction',
        'pt': 'Reivindicar transação'
      }+
      {
        'en': 'Getting estimated fees is not successful.',
        'pt': 'Não foi possível obter as taxas estimadas.'
      }+
      {
        'en': 'Buy using telegram',
        'pt': 'Compre usando telegram'
      }+
      {
        'en': 'Instant Bitcoin',
        'pt': 'Bitcoin Instantâneo'
      }+
      {
        'en': 'Send a pix and we will credit your wallet',
        'pt': 'Envie um pix e creditaremos sua carteira'
      }+
      {
        'en': 'Pix Address',
        'pt': 'Endereço Pix'
      }+
      {
        'en': 'Check Pix Transactions',
        'pt': 'Verificar Transações Pix'
      } +
      {
        'en': 'Minimum amount is ',
        'pt': 'O valor mínimo é '
      } +
      {
        'en': 'You have reached the daily limit',
        'pt': 'Você atingiu o limite diário'
      } +
      {
        'en': 'An error has occurred. Please check your internet connection or contact support',
        'pt': 'Ocorreu um erro. Por favor, verifique sua conexão com a internet ou contate o suporte'
      } +
      {
        'en': 'You can transfer up to',
        'pt': 'Você pode transferir até '
      } +
      {
        'en': ' today',
        'pt': ' hoje'
      } +
      {
        'en': 'Insert an amount',
        'pt': 'Insira um valor'
      } +
      {
        'en': 'You will receive: ',
        'pt': 'Você receberá: '
      } +
      {
        'en': 'Generate Pix code',
        'pt': 'Gerar código Pix'
      } +
      {
        'en': 'No Pix transactions',
        'pt': 'Nenhuma transação Pix'
      } +
      {
        'en': 'Received: ',
        'pt': 'Recebido: '
      } +
      {
        'en': 'Tap to view receipt',
        'pt': 'Toque para ver o recibo'
      } +
      {
        'en': 'Transaction still pending, or maximum value of 5000 per CPF has been reached and depix will be transferred on next available day',
        'pt': 'Transação ainda pendente, ou o valor máximo de 5000 por CPF foi atingido e o depix será transferido no próximo dia disponível'
      } +
      {
        'en': 'Charge your wallet',
        'pt': 'Carregue sua carteira'
      } +
      {
        'en': 'Get Real stablecoins, and convert them to Bitcoin',
        'pt': 'Obtenha stablecoins de Real e converta-os em Bitcoin'
      } +
      {
        'en': 'Simply send us a pix with your unique code',
        'pt': 'Simplesmente nos envie um pix com seu código único'
      } +
      {
        'en': 'Send a pix with the to the key we provide you, and we will credit your wallet',
        'pt': 'Envie um pix com a chave que fornecemos a você, e creditaremos sua carteira'
      } +
      {
        'en': 'Your wallet did not get credited?',
        'pt': 'Sua carteira não foi creditada?'
      } +
      {
        'en': 'Contact us via our support in settings and we will help you',
        'pt': 'Contate-nos através do nosso suporte nas configurações e nós ajudaremos você'
      } +
      {
        'en': 'You can not send more than 5000 BRL per day',
        'pt': 'Você não pode enviar mais de 5000 BRL por dia'
      } +
      {
        'en': 'If you need to send more, contact us via our support in settings, and we will help you',
        'pt': 'Se você precisar enviar mais, contate-nos através do nosso suporte nas configurações, e nós ajudaremos você'
      } +
      {
        'en': 'There was an error saving your code. Please try again or contact support',
        'pt': 'Houve um erro ao salvar seu código. Por favor, tente novamente ou contate o suporte'
      } +
      {
        'en': 'Skip',
        'pt': 'Pular'
      } +
      {
        'en': 'Done',
        'pt': 'Concluído'
      } +
      {
        'en': 'Receive',
        'pt': 'Receber'
      } +
      {
        'en': 'Send',
        'pt': 'Enviar'
      } +
      {
        'en': 'Error please contact support',
        'pt': 'Erro, por favor, contate o suporte'
      } +
      {
        'en': 'PIX received',
        'pt': 'PIX recebido'
      } +
      {
        'en': 'Pix received but transfer limit exceeded, you will receive the amount in 24h. If you wish to receive it sooner, please contact support',
        'pt': 'Pix recebido, mas o limite de transferência foi excedido, você receberá o valor em 24h. Se desejar recebê-lo mais cedo, entre em contato com o suporte'
      } +
      {
        'en': 'Become sovereign and freely opt out of the system.',
        'pt': 'Seja soberano e opte por sair do sistema livremente.'
      }  +
      {
        'en': 'Total bitcoin balance:',
        'pt': 'Saldo total de bitcoin:'
      } +
      {
        'en': 'Change',
        'pt': 'Alterar'
      } +
      {
        'en': 'Services',
        'pt': 'Serviços'
      } +
      {
        'en': 'Wallets',
        'pt': 'Carteiras'
      } +
      {
        'en': 'Liquid',
        'pt': 'Liquid'
      } +
      {
        'en': 'PIX received',
        'pt': 'PIX recebido'
      } +
      {
        'en': 'Pix received but transfer limit exceeded, you will receive the amount in 24h. If you wish to receive it sooner, please contact support',
        'pt': 'Pix recebido, mas o limite de transferência foi excedido, você receberá o valor em 24h. Se desejar recebê-lo mais cedo, entre em contato com o suporte'
      } +
      {
        'en': 'Become sovereign and freely opt out of the system.',
        'pt': 'Seja soberano e opte por sair do sistema livremente.'
      } +
      {
        'en': 'Security',
        'pt': 'Segurança'
      } +
      {
        'en': 'Logout',
        'pt': 'Sair'
      } +
      {
        'en': 'Transaction History',
        'pt': 'Histórico de Transações'
      } +
      {
        'en': 'Blockchain Explorer',
        'pt': 'Explorador de Blockchain'
      } +
      {
        'en': 'Confirmations Required',
        'pt': 'Confirmações Necessárias'
      } +
      {
        'en': 'Remaining Balance',
        'pt': 'Saldo Restante'
      } +
      {
        'en': 'Network Fee',
        'pt': 'Taxa de Rede'
      } +
      {
        'en': 'Pending Transactions',
        'pt': 'Transações Pendentes'
      } +
      {
        'en': 'View More',
        'pt': 'Ver Mais'
      } +
      {
        'en': 'Failed',
        'pt': 'Falhou'
      } +
      {
        'en': 'Retry',
        'pt': 'Tentar Novamente'
      } +
      {
        'en': 'Settings',
        'pt': 'Configurações'
      } +
      {
        'en': 'Create wallet',
        'pt': 'Criar carteira'
      } +
      {
        'en': 'Recover wallet',
        'pt': 'Recuperar carteira'
      } +
      {
        'en': 'Delete Account?',
        'pt': 'Excluir Conta?'
      } +
      {
        'en': 'All information will be permanently deleted.',
        'pt': 'Todas as informações serão permanentemente excluídas.'
      } +
      {
        'en': 'Interactive Mode',
        'pt': 'Modo Interativo'
      } +
      {
        'en': 'View Accounts',
        'pt': 'Ver Contas',
      } +
      {
        'en': 'Total balance',
        'pt': 'Saldo total',
      } +
      {
        'en': 'Dashboards',
        'pt': 'Dashboards',
      } +
      {
        'en': 'Educação Real',
        'pt': 'Educação Real',
      } +
      {
        'en': 'Courses',
        'pt': 'Cursos',
      } +
      {
        'en': 'ETF Tracker',
        'pt': 'Rastreador de ETF',
      } +
      {
        'en': 'Retirement Calculator',
        'pt': 'Calculadora de Aposentadoria',
      } +
      {
        'en': 'Bitcoin Converter',
        'pt': 'Conversor de Bitcoin',
      } +
      {
        'en': 'DCA Calculator',
        'pt': 'Calculadora DCA',
      } +
      {
        'en': 'Bitcoin Counterflow Strategy',
        'pt': 'Estratégia Counterflow de Bitcoin',
      } +
      {
        'en': 'Charts',
        'pt': 'Gráficos',
      } +
      {
        'en': 'Liquidation Zone',
        'pt': 'Zona de Liquidação',
      }  +
      {
        'en': 'Transferred Today:',
        'pt': 'Transferido Hoje:',
      } +
      {
        'en': 'Transferred This Week:',
        'pt': 'Transferido Esta Semana:',
      }+
      {
        'en': 'history',
        'pt': 'histórico',
      }+
      {
        'en': 'Transaction still pending',
        'pt': 'Transação ainda pendente',
      }+
      {
        'en': 'An error has occurred. Please check your internet connection or contact support',
        'pt': 'Ocorreu um erro. Por favor, verifique sua conexão com a internet ou contate o suporte',
      }+
      {
        'en': 'Transaction Details',
        'pt': 'Detalhes da Transação',
      } +
      {
        'en': 'About the transaction',
        'pt': 'Sobre a transação',
      } +
      {
        'en': 'Date',
        'pt': 'Data',
      } +
      {
        'en': 'Pending',
        'pt': 'Pendente',
      } +
      {
        'en': 'Origin',
        'pt': 'Origem',
      } +
      {
        'en': 'Name',
        'pt': 'Nome',
      } +
      {
        'en': 'Completed',
        'pt': 'Concluída',
      } +
      {
        'en': 'Download document',
        'pt': 'Baixar documento',
      }+
      {
        'en': 'Chat with us about anything',
        'pt': 'Converse conosco sobre qualquer coisa',
      } +
      {
        'en': 'Claim your Boltz transactions',
        'pt': 'Reivindique suas transações Boltz',
      } +
      {
        'en': 'User Section',
        'pt': 'Seção do Usuário',
      } +
      {
        'en': 'Manage your anonymous account',
        'pt': 'Gerencie sua conta anônima',
      } +
      {
        'en': 'Instant',
        'pt': 'Instantâneo',
      } +
      {
        'en': 'See Full History',
        'pt': 'Ver Histórico Completo',
      } +
      {
        'en': 'Open support chat',
        'pt': 'Abrir chat de suporte',
      } +
      {
        'en': 'Reset Chat Session',
        'pt': 'Reset da Sessão de Chat',
      } +
      {
        'en': 'Lightning transactions',
        'pt': 'Transações Lightning',
      }+
      {
        'en': 'User Details',
        'pt': 'Detalhes do Usuário',
      } +
      {
        'en': 'Payment ID',
        'pt': 'ID de Pagamento',
      } +
      {
        'en': 'Affiliate code for sharing',
        'pt': 'Código de afiliado para compartilhar',
      } +
      {
        'en': 'Referred by',
        'pt': 'Indicado por',
      } +
      {
        'en': 'Recovery Code',
        'pt': 'Código de Recuperação',
      } +
      {
        'en': 'Hint: Please store your recovery code somewhere safe. There is no other way to recover your account if you lose this code.',
        'pt': 'Dica: Guarde seu código de recuperação em um local seguro. Não há outra maneira de recuperar sua conta se você perder este código.',
      } +
      {
        'en': 'Affiliate Portal',
        'pt': 'Portal de Afiliados',
      } +
      {
        'en': 'Track your performance and access exclusive resources.',
        'pt': 'Acompanhe seu desempenho e acesse recursos exclusivos.',
      } +
      {
        'en': 'Go to Affiliate Portal',
        'pt': 'Ir para o Portal de Afiliados',
      } +
      {
        'en': 'Welcome,',
        'pt': 'Bem-vindo,',
      } +
      {
        'en': 'This section is completely anonymous and does not require any personal information.',
        'pt': 'Esta seção é completamente anônima e não requer nenhuma informação pessoal.',
      } +
      {
        'en': 'Create anonymous account',
        'pt': 'Criar conta anônima',
      }+
      {
        'en': 'Anonymous account created successfully!',
        'pt': 'Conta anônima criada com sucesso!',
      } +
      {
        'en': 'Add funds to your wallet. Convert stablecoins to Bitcoin quickly and easily.',
        'pt': 'Adicione fundos à sua carteira. Converta stablecoins em Bitcoin de forma rápida e fácil.',
      } +
      {
        'en': 'Get your PIX key',
        'pt': 'Obtenha sua chave PIX',
      } +
      {
        'en': 'Receive an exclusive Pix key to add funds. This key is unique for each transaction.',
        'pt': 'Receba uma chave Pix exclusiva para adicionar fundos. Esta chave é única para cada transação.',
      } +
      {
        'en': 'Send us a PIX',
        'pt': 'Envie-nos um PIX',
      } +
      {
        'en': 'Make a Pix payment using the provided exclusive key. Your funds will be credited to your wallet.',
        'pt': 'Faça um pagamento Pix usando a chave exclusiva fornecida. Seus fundos serão creditados em sua carteira.',
      } +
      {
        'en': 'Daily limit',
        'pt': 'Limite diário',
      } +
      {
        'en': 'Daily transaction limit: BRL 5000. Need to send more? Contact our support.',
        'pt': 'Limite diário de transações: BRL 5000. Precisa enviar mais? Entre em contato com nosso suporte.',
      } +
      {
        'en': 'Enter recovery code',
        'pt': 'Digite o código de recuperação',
      } +
      {
        'en': 'Recover',
        'pt': 'Recuperar',
      } +
      {
        'en': 'Affiliate not found',
        'pt': 'Afiliado não encontrado',
      } +
      {
        'en': 'Invalid liquid address',
        'pt': 'Endereço Liquid inválido',
      } +
      {
        'en': 'The code you have inserted is not correct',
        'pt': 'O código que você inseriu está incorreto',
      } +
      {
        'en': 'The affiliate code can have a maximum of 8 characters, no spaces or special characters',
        'pt': 'O código de afiliado pode ter no máximo 8 caracteres, sem espaços ou caracteres especiais',
      } +
      {
        'en': 'The affiliate code you inserted already exists',
        'pt': 'O código de afiliado que você inseriu já existe',
      } +
      {
        'en': 'Affiliate',
        'pt': 'Afiliado',
      } +
      {
        'en': 'Connect with other users and earn sats!',
        'pt': 'Conecte-se com outros usuários e ganhe sats!',
      } +
      {
        'en': 'Enter your affiliate code or create a new code to receive discounts.',
        'pt': 'Insira seu código de afiliado ou crie um novo código para receber descontos.',
      } +
      {
        'en': 'Insert Affiliate Code',
        'pt': 'Inserir Código de Afiliado',
      } +
      {
        'en': 'Recovery code copied to clipboard',
        'pt': 'Código de recuperação copiado para a área de transferência',
      } +
      {
        'en': 'Share',
        'pt': 'Compartilhar',
      } +
      {
        'en': 'Copy',
        'pt': 'Copiar',
      } +
      {
        'en': 'Affiliate code created successfully',
        'pt': 'Código de afiliado criado com sucesso',
      } +
      {
        'en': 'Enter a value to send',
        'pt': 'Insira um valor para enviar',
      } +
      {
        'en': 'Slide to Swap',
        'pt': 'Deslize para Trocar',
      } +{
    'en': 'Affiliate Section',
    'pt': 'Seção de Afiliados',
  } +
      {
        'en': 'Bronze',
        'pt': 'Bronze',
      } +
      {
        'en': 'Silver',
        'pt': 'Prata',
      } +
      {
        'en': 'Gold',
        'pt': 'Ouro',
      } +
      {
        'en': 'Diamond',
        'pt': 'Diamante',
      } +
      {
        'en': 'Your Affiliate Code to Share',
        'pt': 'Seu Código de Afiliado para Compartilhar',
      } +
      {
        'en': 'Registered:',
        'pt': 'Registrado:',
      } +
      {
        'en': 'Total Earnings',
        'pt': 'Ganhos Totais',
      } +
      {
        'en': 'Number of Referrals',
        'pt': 'Número de Indicações',
      } +
      {
        'en': 'Show Earnings Over Time',
        'pt': 'Mostrar Ganhos',
      } +
      {
        'en': 'Would you like to become an affiliate?',
        'pt': 'Gostaria de se tornar um afiliado?',
      } +
      {
        'en': 'Become an Affiliate',
        'pt': 'Torne-se um Afiliado',
      } +
      {
        'en': 'Submit',
        'pt': 'Enviar',
      } +
      {
        'en': 'Affiliate code created successfully',
        'pt': 'Código de afiliado criado com sucesso',
      } +
      {
        'en': 'An error has occurred. Please check your internet connection or contact support',
        'pt': 'Ocorreu um erro. Verifique sua conexão com a internet ou entre em contato com o suporte',
      } +
      {
        'en': 'Earnings Over Time',
        'pt': 'Ganhos ao Longo do Tempo',
      } +
      {
        'en': 'No earnings data available',
        'pt': 'Nenhum dado de ganhos disponível',
      } +
      {
        'en': 'Affiliate Earnings',
        'pt': 'Ganhos de Afiliado',
      } +
      {
        'en': 'Liquid Address to receive commission',
        'pt': 'Endereço Liquid para receber comissão',
      } +
      {
        'en': 'Affiliate Code',
        'pt': 'Código de Afiliado',
      } +
      {
        'en': 'You were referred by',
        'pt': 'Você foi indicado por',
      } +
      {
        'en': 'Inserted Affiliate Code copied to clipboard',
        'pt': 'Código de Afiliado inserido copiado para a área de transferência',
      } +
      {
        'en': 'Created Affiliate Code copied to clipboard',
        'pt': 'Código de Afiliado criado copiado para a área de transferência',
      }+
      {
        'en': 'You are Bronze!',
        'pt': 'Você é Bronze!',
      } +
      {
        'en': 'You are Silver!',
        'pt': 'Você é Prata!',
      } +
      {
        'en': 'You are Gold!',
        'pt': 'Você é Ouro!',
      } +
      {
        'en': 'You are Diamond!',
        'pt': 'Você é Diamante!',
      } +
      {
        'en': 'Tier Locked',
        'pt': 'Nível Bloqueado',
      } +
      {
        'en': 'With 5000 DEPIX, you have reached the Gold tier.',
        'pt': 'Com 5000 DEPIX, você atingiu o nível Ouro.',
      } +
      {
        'en': 'With 20000 DEPIX, you have reached the Diamond tier.',
        'pt': 'Com 20000 DEPIX, você atingiu o nível Diamante.',
      } +
      {
        'en': 'You need 5000 DEPIX to unlock the Gold tier.',
        'pt': 'Você precisa de 5000 DEPIX para desbloquear o nível Ouro.',
      } +
      {
        'en': 'You need 20000 DEPIX to unlock the Diamond tier.',
        'pt': 'Você precisa de 20000 DEPIX para desbloquear o nível Diamante.',
      } +
      {
        'en': 'Current fee is 1% per affiliate in perpetuity.',
        'pt': 'Taxa atual é de 1% por afiliado perpetuamente.',
      } +
      {
        'en': 'Current fee is 0.2% per affiliate in perpetuity until you reach 20K in value purchased by your referrals.',
        'pt': 'Taxa atual é de 0.2% por afiliado perpetuamente até você atingir 20K em valor comprado por suas indicações.',
      } +
      {
        'en': 'You have not unlocked the Gold tier yet. Unlock it by reaching 5000 in value purchased by your referrals.',
        'pt': 'Você ainda não desbloqueou o nível Ouro. Desbloqueie-o ao atingir 5000 DEPIX comprados por suas indicações.',
      } +
      {
        'en': 'You have not unlocked the Diamond tier yet. Unlock it by reaching 20000 in value purchased by your referrals.',
        'pt': 'Você ainda não desbloqueou o nível Diamante. Desbloqueie-o ao atingir 20000 DEPIX comprados por suas indicações.',
      } +
      {
        'en': 'You have not unlocked the Ouro tier yet. Unlock it by reaching 5000 in value purchased by your referrals.',
        'pt': 'Você ainda não desbloqueou o nível Ouro. Desbloqueie ao atingir 5000 DEPIX comprados por suas indicações.',
      } +
      {
        'en': 'You need 5000 DEPIX to unlock the Ouro tier.',
        'pt': 'Você precisa de 5000 DEPIX para desbloquear o nível Ouro.',
      } +
      {
        'en': 'You have not unlocked the Prata tier yet. Unlock it by reaching 2500 in value purchased by your referrals.',
        'pt': 'Você ainda não desbloqueou o nível Prata. Desbloqueie ao atingir 2500 DEPIX comprados por suas indicações.',
      } +
      {
        'en': 'You need 2500 DEPIX to unlock the Prata tier.',
        'pt': 'Você precisa de 2500 DEPIX para desbloquear o nível Prata.',
      } +
      {
        'en': 'You have not unlocked the Diamante tier yet. Unlock it by reaching 20000 in value purchased by your referrals.',
        'pt': 'Você ainda não desbloqueou o nível Diamante. Desbloqueie ao atingir 20000 DEPIX comprados por suas indicações.',
      } +
      {
        'en': 'You need 20000 DEPIX to unlock the Diamante tier.',
        'pt': 'Você precisa de 20000 DEPIX para desbloquear o nível Diamante.',
      } +
      {
        'en': 'Close',
        'pt': 'Fechar',
      } +
      {
        'en': 'With ',
        'pt': 'Com '
      }  +
      {
        'en': ' DEPIX, you have reached the ',
        'pt': ' DEPIX, você atingiu o '
      }  +
      {
        'en': 'Contact our support to get a custom affiliate code',
        'pt': 'Contate nosso suporte para obter um código de afiliado personalizado'
      }  +
      {
        'en': 'Insufficient funds',
        'pt': 'Fundos insuficientes'
      }  +
      {
        'en': 'Choose your fee:',
        'pt': 'Escolha sua taxa:'
      }  +
      {
        'en': 'Fee: 1.5% + 1,98 BRL (Affiliate Discount)',
        'pt': 'Taxa: 1,5% + 1,98 BRL (Desconto de Afiliado)'
      } +
      {
        'en': 'Fee: 2% + 1,98 BRL (No Affiliate Discount)',
        'pt': 'Taxa: 2% + 1,98 BRL (Sem Desconto de Afiliado)'
      } +
      {
        'en': 'Fee: 2% + 1,98 BRL',
        'pt': 'Taxa: 2% + 1,98 BRL'
      } +
      {
        'en': 'Waiting',
        'pt': 'Aguardando'
      } +
      {
        'en': 'Confirmation block',
        'pt': 'Bloco de confirmação'
      } +
      {
        'en': 'Amounts',
        'pt': 'Quantias'
      } +
      {
        'en': 'Search on Mempool',
        'pt': 'Pesquisar no Mempool'
      } +
      {
        'en': 'Liquid Transaction Details',
        'pt': 'Detalhes da Transação Liquid'
      } +
      {
        'en': 'History',
        'pt': 'Histórico'
      } +
      {
        'en': 'More Details',
        'pt': 'Mais Detalhes'
      } +
      {
        'en': 'Fees',
        'pt': 'Taxas'
      } +
      {
        'en': 'Original amount',
        'pt': 'Quantia original'
      } +
      {
        'en': 'You earn 1% per referral in perpetuity',
        'pt': 'Você ganha 1% por indicação perpetuamente'
      } +
      {
        'en': 'You earn 0.2% per referral in perpetuity',
        'pt': 'Você ganha 0.2% por indicação perpetuamente'
      } +
      {
        'en': 'Receiving Bitcoin fee:',
        'pt': 'Taxa de recebimento de Bitcoin:'
      } +
      {
        'en': 'Create Affiliate Code',
        'pt': 'Criar Código de Afiliado'
      } +
      {
        'en': 'Amount is below minimum peg in amount',
        'pt': 'A quantia está abaixo da quantia mínima de conversão'
      } +
      {
        'en': 'Please ensure the CPF/CNPJ you enter matches the CPF/CNPJ registered to your Pix or the transfer may fail',
        'pt': 'Por favor, certifique-se de que o CPF/CNPJ que insere corresponde ao CPF/CNPJ registrado em seu Pix ou a transferência pode falhar'
      } +
      {
        'en': 'Transaction will expire in:',
        'pt': 'A transação expirará em:'
      } +
      {
        'en': "Awaiting payment",
        'pt': 'Aguardando pagamento'
      } +
      {
        'en': "Transaction failed",
        'pt': 'Transação falhou'
      } +
      {
        'en': "Waiting payment",
        'pt': 'Aguardando Pix'
      } +
      {
        'en': "Time left:",
        'pt': 'Tempo restante:'
      } +
      {
        'en': "Transfer ID copied",
        'pt': 'ID de transferência copiado'
      } +
      {
        'en': "Txid copied",
        'pt': 'Txid copiado'
      } +
      {
        'en': "Unable to get minimum amount",
        'pt': 'Não foi possível obter a quantia mínima'
      } +
      {
        'en': "Minimum amount:",
        'pt': 'Quantia mínima:'
      } +
      {
        'en': "About ",
        'pt': 'Cerca de '
      } +
      {
        'en': "Failed to get liquid address index",
        'pt': 'Falha ao obter o índice do endereço Liquid'
      } +
      {
        'en': "Your wallet does not belong to the account you are trying to charge",
        'pt': 'Sua carteira não pertence à conta que você está tentando carregar'
      } +
      {
        'en': "Payment received",
        'pt': 'Pagamento recebido'
      } +
      {
        'en': "Processing transfer",
        'pt': 'Processando transferência'
      } +
      {
        'en': "Please wait a few minutes and try again",
        'pt': 'Aguarde alguns minutos e tente novamente'
      } +
      {
        'en': "Invalid CPF/CNPJ",
        'pt': 'CPF/CNPJ inválido'
      } +
      {
        'en': "Please enter an amount",
        'pt': 'Por favor, insira uma quantia'
      } +
      {
        'en': "Swap failed, please contact support",
        'pt': 'Troca falhou, por favor, contate o suporte'
      } +
      {
        'en': 'Send with Liquid Balance',
        'pt': 'Enviar com Saldo Liquid'
      } +
      {
        'en': 'Send with Bitcoin Balance',
        'pt': 'Enviar com Saldo Bitcoin'
      }  +
      {
        'en': "Swap failed, please contact support",
        'pt': 'Troca falhou, por favor, contate o suporte'
      } +
      {
        'en': 'Send with Liquid Balance',
        'pt': 'Enviar com Saldo Liquid'
      } +
      {
        'en': 'Send with Bitcoin Balance',
        'pt': 'Enviar com Saldo Bitcoin'
      } +
      {
        'en': 'Select Electrum Node',
        'pt': 'Selecionar um Nó Electrum'
      } +
      {
        'en': 'Convert your DEPIX to bitcoin',
        'pt': 'Converta seus DEPIX em bitcoin'
      } +
      {
        'en': 'Your balance will update soon',
        'pt': 'Seu saldo será atualizado em breve'
      } +  {
    'en': 'All Swaps',
    'pt': 'Todas as trocas'
  } +
      {
        'en': 'Fiat Swaps',
        'pt': 'Trocas Fiat'
      } +
      {
        'en': 'Layer Swaps',
        'pt': 'Trocas de Camada'
      } +
      {
        'en': 'Pix History',
        'pt': 'Histórico Pix'
      } +
      {
        'en': 'Transaction in progress, please wait.',
        'pt': 'Transação em andamento, por favor, aguarde.'
      } +
      {
        'en': 'Total fees',
        'pt': 'Taxas totais'
      } +
      {
        'en': 'Total amount to send',
        'pt': 'Valor total a enviar'
      } +
      {
        'en': 'Lightning swap',
        'pt': 'Troca Lightning'
      } +
      {
        'en': 'Receiving',
        'pt': 'Recebendo'
      } +
      {
        'en': 'Sending',
        'pt': 'Enviando'
      } +
      {
        'en': 'Expiry block',
        'pt': 'Bloco de expiração'
      } +
      {
        'en': 'Lightning Swaps',
        'pt': 'Trocas Lightning'
      } +
      {
        'en': 'Confirm PIN',
        'pt': 'Confirmar PIN'
      } +
      {
        'en': 'PINs do not match',
        'pt': 'PINs não correspondem'
      } +
      {
        'en': 'Choose a 6-digit PIN',
        'pt': 'Escolha um PIN de 6 dígitos'
      } +
      {
        'en': 'attempts remaining',
        'pt': 'tentativas restantes'
      } +
      {
        'en': 'Please authenticate to view seed words',
        'pt': 'Por favor, autentique-se para ver as seeds'
      } +
      {
        'en': 'Support',
        'pt': 'Apoio'
      } +
      {
        'en': 'Price: ',
        'pt': 'Preço: '
      } +
      {
        'en': 'Fixed Fee: ',
        'pt': 'Taxa Fixa: '
      } +
      {
        'en': 'Delete Wallet?',
        'pt': 'Excluir Carteira?'
      } +
      {
        'en': 'Select an option below to proceed.',
        'pt': 'Selecione uma opção abaixo para continuar.'
      } +
      {
        'en': 'Delete Local Wallet',
        'pt': 'Excluir Carteira Local'
      } +
      {
        'en': 'Remove wallet data from this device',
        'pt': 'Remover dados da carteira deste dispositivo'
      } +
      {
        'en': 'Delete Server Data and Local Wallet',
        'pt': 'Excluir Dados do Servidor e Carteira Local'
      } +
      {
        'en': 'Remove your data from the server and this device.',
        'pt': 'Remova seus dados do servidor e deste dispositivo.'
      } +
      {
        'en': 'Delete Local Wallet?',
        'pt': 'Excluir Carteira Local?'
      } +
      {
        'en': 'Are you sure you want to delete the wallet?',
        'pt': 'Tem certeza de que deseja excluir a carteira?'
      } +
      {
        'en': 'Delete Server Data and Local Wallet?',
        'pt': 'Excluir Dados do Servidor e Carteira Local?'
      } +
      {
        'en': 'Your server data and local wallet will be permanently deleted, and you will not receive any more fees from any of your affiliates.',
        'pt': 'Seus dados do servidor e carteira local serão excluídos permanentemente, e você não receberá mais taxas de nenhum de seus afiliados.'
      } +
      {
        'en': 'Register for Custodial Lightning',
        'pt': 'Registrar para Lightning Custodial'
      } +
      {
        'en': 'A username and password will be derived from your private key. This will be used to access your custodial Lightning wallet.',
        'pt': 'Um nome de usuário e senha serão derivados de sua chave privada. Isso será usado para acessar sua carteira Lightning custodial.'
      } +
      {
        'en': 'Register',
        'pt': 'Registrar'
      } +
      {
        'en': 'Bitcoin',
        'pt': 'Bitcoin'
      } +
      {
        'en': 'Custodial Lightning Info',
        'pt': 'Informações sobre Lightning Custodial'
      }+
      {
        'en': 'Custodial Lightning Warning',
        'pt': 'Aviso sobre Lightning Custodial'
      } +
      {
        'en': 'By using this custodial Lightning service, your funds are held by our partner Coinos. Satsails does not have control over these funds. You agree to have your funds held by Coinos.',
        'pt': 'Ao usar este serviço Lightning custodial, seus fundos são mantidos por nosso parceiro Coinos. A Satsails não tem controle sobre esses fundos. Você concorda que seus fundos serão mantidos pela Coinos.'
      } +
      {
        'en': 'Username',
        'pt': 'Nome de usuário'
      } +
      {
        'en': 'Visit Coinos',
        'pt': 'Visite a Coinos'
      } +
      {
        'en': 'Lightning Balance',
        'pt': 'Saldo Lightning'
      }  +
      {
        'en': 'Lightning Fee Information',
        'pt': 'Informações sobre Taxas Lightning'
      } +
      {
        'en': 'Lightning fees are dynamic. We must store at least 0.5% of the transaction value for routing fees. Any unused amount will be returned to your wallet.',
        'pt': 'As taxas Lightning são dinâmicas. Precisamos armazenar pelo menos 0,5% do valor da transação para taxas de roteamento. Qualquer valor não utilizado será retornado à sua carteira.'
      } +
      {
        'en': 'Token is missing or invalid',
        'pt': 'Token está faltando ou é inválido'
      } +
      {
        'en': 'Failed to create invoice',
        'pt': 'Falha ao criar fatura'
      } +
      {
        'en': 'Failed to send payment',
        'pt': 'Falha ao enviar pagamento'
      } +
      {
        'en': 'Failed to fetch balance and transactions',
        'pt': 'Falha ao buscar saldo e transações'
      } +
      {
        'en': 'balance',
        'pt': 'saldo'
      } +
      {
        'en': 'payments',
        'pt': 'pagamentos'
      }    +
      {
        'en': 'Balance insufficient to cover fees',
        'pt': 'Saldo insuficiente para cobrir taxas'
      } +
      {
        'en': 'Amount cannot be zero',
        'pt': 'O valor não pode ser zero'
      } +
      {
        'en': 'Insufficient funds to pay for fees',
        'pt': 'Fundos insuficientes para pagar taxas'
      } +
      {
        'en': 'Payment Received!',
        'pt': 'Pagamento Recebido!'
      } +
      {
        'en': 'sats received!',
        'pt': 'sats recebidos!'
      } +
      {
        'en': 'The first 3 purchases with only 10 brl. After that, the minimum value will be 250 brl',
        'pt': 'As 3 primeiras compras com apenas 10 brl. Depois disso, o valor mínimo será de 250 brl'
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
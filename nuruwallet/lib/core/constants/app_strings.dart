/// All user-facing strings in one place.
/// Centralising here makes future Swahili translation straightforward —
/// just swap the values and every widget picks up the change.
abstract final class AppStrings {
  // --- App ---
  static const appName = 'NuruWallet';
  static const tagline = 'Illuminate Your Finances';

  // --- Navigation ---
  static const navHome = 'Home';
  static const navTransactions = 'Transactions';
  static const navBudget = 'Budget';
  static const navAnalytics = 'Analytics';
  static const navGoals = 'Goals';
  static const navSettings = 'Settings';

  // --- Dashboard ---
  static const totalBalance = 'Total Balance';
  static const incomeThisMonth = 'Income';
  static const expenseThisMonth = 'Expenses';
  static const netSavings = 'Net Savings';
  static const recentTransactions = 'Recent Transactions';
  static const seeAll = 'See All';
  static const budgetProgress = 'Budget Progress';
  static const noTransactions = 'No transactions yet';
  static const noTransactionsHint = 'Tap + to record your first transaction';

  // --- Transactions ---
  static const addTransaction = 'Add Transaction';
  static const editTransaction = 'Edit Transaction';
  static const expense = 'Expense';
  static const income = 'Income';
  static const amount = 'Amount';
  static const category = 'Category';
  static const account = 'Account';
  static const date = 'Date';
  static const note = 'Note (optional)';
  static const noteHint = 'e.g. Bus fare to NIT';
  static const recurring = 'Recurring';
  static const save = 'Save';
  static const cancel = 'Cancel';
  static const delete = 'Delete';
  static const edit = 'Edit';
  static const deleteTransactionConfirm =
      'Delete this transaction? This cannot be undone.';

  // --- Categories ---
  static const foodDrinks = 'Food & Drinks';
  static const transport = 'Transport';
  static const housingRent = 'Housing & Rent';
  static const health = 'Health';
  static const entertainment = 'Entertainment';
  static const education = 'Education';
  static const shopping = 'Shopping';
  static const utilities = 'Utilities';
  static const savings = 'Savings';
  static const other = 'Other';

  // --- Accounts ---
  static const cashWallet = 'Cash Wallet';
  static const mpesa = 'M-Pesa';
  static const bankAccount = 'Bank Account';
  static const savingsJar = 'Savings Jar';
  static const netWorth = 'Net Worth';
  static const myAccounts = 'My Accounts';
  static const addAccount = 'Add Account';
  static const transferBetweenAccounts = 'Transfer';

  // --- Goals ---
  static const savingsGoals = 'Savings Goals';
  static const addGoal = 'Add Goal';
  static const goalName = 'Goal Name';
  static const targetAmount = 'Target Amount';
  static const deadline = 'Deadline';
  static const goalCompleted = 'Goal Completed!';
  static const addContribution = 'Add Contribution';

  // --- Currency ---
  static const primaryCurrency = 'Primary Currency';
  static const ratesUpdated = 'Rates updated';
  static const ratesStale = 'Using cached rates from';
  static const fetchingRates = 'Updating exchange rates...';

  // --- Security ---
  static const enterPin = 'Enter your PIN';
  static const createPin = 'Create a PIN';
  static const confirmPin = 'Confirm your PIN';
  static const pinMismatch = 'PINs do not match. Try again.';
  static const enableBiometric = 'Use fingerprint to unlock';
  static const appLocked = 'NuruWallet is locked';
  static const unlockWithPin = 'Enter PIN to unlock';

  // --- Settings ---
  static const settings = 'Settings';
  static const theme = 'Theme';
  static const lightMode = 'Light Mode';
  static const darkMode = 'Dark Mode';
  static const cloudBackup = 'Cloud Backup';
  static const exportData = 'Export All Data';
  static const deleteAllData = 'Delete All Data';
  static const deleteAllDataConfirm =
      'This will permanently erase ALL your data. This cannot be undone.';
  static const aboutNuruWallet = 'About NuruWallet';
  static const version = 'Version';

  // --- Errors ---
  static const errorGeneric = 'Something went wrong. Please try again.';
  static const errorNoInternet = 'No internet connection.';
  static const errorAmountRequired = 'Please enter an amount.';
  static const errorAmountInvalid = 'Please enter a valid amount.';
  static const errorCategoryRequired = 'Please select a category.';
}

class Wallet{
  Wallet(this.name,this.cash,this.expenses);
  String name;
  double cash;
  List<Expence> expenses = [];
}

class Expence{
  Expence(this.name,this.cash,this.date);
  String name;
  double cash;
  String date;
}

class WalletCategory{
  WalletCategory(this.name,this.cash,this.expence);
  
  String name;
  double cash=0;
  List<Expence> expence = List<Expence>();

  void addExpence(Expence ex){
    expence.add(ex);
    cash+=ex.cash;
  }
}

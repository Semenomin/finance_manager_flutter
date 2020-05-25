class Wallet{
  Wallet(this.name,this.cash);
  String name;
  double cash;

  void addIncome(double inc){
    cash = cash+inc;
  }
}

class Expence{
  Expence(this.name,this.cash,this.date);
  String name;
  double cash;
  String date;
}

class Income{
  Income(this.name,this.cash,this.date);
  String name;
  double cash;
  String date;
}

class WalletCategory{
  WalletCategory(this.name,this.cash,this.expence,this.income);
  String name;
  double cash=0;
  List<Expence> expence = List<Expence>();
  List<Income> income = List<Income>();

  void addExpence(Expence ex){
    expence.add(ex);
    cash+=ex.cash;
  }

  void addIncome(Income inc,List<Wallet> wall){
    income.add(inc);
    for(Wallet wallet in wall){
      switch (wallet.name){
        case "necessary":{
          wallet.addIncome((inc.cash*55)/100);
        }
        break;
        case "entertainment":{
          wallet.addIncome((inc.cash*10)/100);
        }
        break;
        case "saving":{
          wallet.addIncome((inc.cash*10)/100);
        }
        break;
        case "education":{
          wallet.addIncome((inc.cash*10)/100);
        }
        break;
        case "reserve":{
          wallet.addIncome((inc.cash*10)/100);
        }
        break;
        case "presents":{
          wallet.addIncome((inc.cash*5)/100);
        }
        break;
      }
    }
  }
}

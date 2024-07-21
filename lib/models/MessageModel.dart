class MessageModel {
  String? messageid;
  String? sender; // sender matlab msg kisne bheja
  String? text; // text matlab msg me likha kya tha
  bool? seen; // seen matlb seen hua ki nahi
  DateTime? createdon; // matlb msg kab seen hua or kab create hua

  // default constructor

  MessageModel(
      {this.sender,
      this.text,
      this.seen,
      this.createdon,
      this.messageid,
      required DateTime creation});

  MessageModel.fromMap(Map<String, dynamic> map) {
    sender = map["sender"];
    messageid = map["messageid"];
    text = map["text"];
    seen = map["seen"];
    createdon = map["createdon"].toDate();
  }

  Map<String, dynamic> toMap() {
    return {
      "sender": sender,
      "text": text,
      "seen": seen,
      "createdon": createdon,
      "messageid": messageid,
    };
  }
}

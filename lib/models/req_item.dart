class ReqItem {
  int reqItemId = 0;
  int itemAmount = 0;
  String description = '';
  String reqDate = '';
  int done = 0;

  ReqItem(dynamic obj) {
    reqItemId = obj['req_item_id'];
    itemAmount = obj['req_item_amount'];
    description = obj['description'];
    reqDate = obj['req_date'];
    done = obj['done'];
  }
  ReqItem.fromMap(Map<String, dynamic> data) {
    reqItemId = data['req_item_id'];
    itemAmount = data['req_item_amount'];
    description = data['description'];
    reqDate = data['req_date'];
    done = data['done'];
  }
  Map<String, dynamic> toMap() => {
        'req_item_id': reqItemId,
        'req_item_amount': itemAmount,
        'req_date': reqDate,
        'description': description,
        'done': done,
      };

  int get req_item_id => reqItemId;
  int get req_item_amount => itemAmount;
  String get req_description => description;
  String get req_date => reqDate;
  int get req_done => done;
}

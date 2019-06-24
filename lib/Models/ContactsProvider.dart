import 'package:contacts_service/contacts_service.dart';

class ContactsProvider {
  List<Contact> phoneContacts = List<Contact>();
  Iterable<Contact> contacts;
  List<String> contactNames = List<String>();

  ContactsProvider() {
    _assignContacts();
  }

  _assignContacts() async {
    contacts = await ContactsService.getContacts();
    for (Contact c in contacts) {
      phoneContacts.add(c);
      contactNames.add(c.displayName);
    }
  }

  List<String> getSuggestions(String query) {
    List<Contact> matches = List<Contact>();
    List<String> matchesNames = List<String>();
    matches.addAll(phoneContacts);

    matches.retainWhere(
        (s) => s.displayName.toLowerCase().contains(query.toLowerCase()));
    matches.forEach((f) {
      matchesNames.add(f.displayName);
      // print("matchesNames: $matchesNames");
      // print("matches: ${f.displayName}");
    });
    // print("matchesNames: $matchesNames");
    return matchesNames;
  }

  List<String> getPhoneNumbers(String contactName) {
    Set<String> phonesNumbers = Set<String>();
    List<Contact> matches = List<Contact>();
    matches.addAll(phoneContacts);
    matches.retainWhere((s) => s.displayName.contains(contactName));
    matches.forEach((cntc) {
      for (Item i in cntc.phones) {
        String number = i.value;
        number = number.replaceAll(RegExp('[\ \+\-\.\,\(\)\/\N\*\#\;]'), "");
        print("length: ${number.length}");
        if (number.length > 10) number = number.substring(number.length - 10);
        phonesNumbers.add(number);
      }
    });
    print("PhoneNumbers: $phonesNumbers");
    return phonesNumbers.toList();
  }
}

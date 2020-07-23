import 'package:contacts_service/contacts_service.dart';

class ContactsProvider {
  Set<String> _contactNames = Set<String>();

  ContactsProvider() {
    _assignContacts();
  }

  _assignContacts() async {
    Iterable<Contact> contacts =
        await ContactsService.getContacts(withThumbnails: false);
    for (Contact c in contacts) {
      _contactNames.add(c.displayName);
    }
  }

  // static Future<List<Contact>> queryContacts(String query) async {
  //   return await ContactsService.getContacts(
  //     query: query,
  //     withThumbnails: false,
  //     photoHighResolution: false,
  //     orderByGivenName: true,
  //   );
  // }

  static Future<List<String>> getSimilarNameSuggestion(String name) async {
    Set<String> matchesNames = Set<String>();
    Iterable<Contact> matches = await ContactsService.getContacts(
      query: name,
      withThumbnails: false,
    );
    matches.forEach((Contact contact) {
      matchesNames.add(contact.displayName);
    });
    print("getSimilarNameSuggestion $matchesNames");
    return matchesNames.toList();
  }

  static Future<List<String>> getContactNumbersFromName(
      String contactName) async {
    Set<String> phonesNumbers = Set<String>();
    Iterable<Contact> matches = await ContactsService.getContacts(
      query: contactName,
      withThumbnails: false,
    );
    matches.forEach((cntc) {
      for (Item i in cntc.phones) {
        String number = i.value;
        // print("Number in getContactNumbersFromName: $number");
        number = stripPhoneNumber(number);
        phonesNumbers.add(number);
      }
    });
    print("getContactNumbersFromName: $phonesNumbers");
    return phonesNumbers.toList();
  }

  static Future<List<String>> getNameFromContactNumber(
      String phoneNumber) async {
    Set<String> matchesNames = Set<String>();
    Iterable<Contact> matches = await ContactsService.getContactsForPhone(
      phoneNumber,
      withThumbnails: false,
    );
    matches.forEach((Contact contact) {
      matchesNames.add(contact.displayName);
    });
    // print("getNameFromContactNumber $matchesNames");
    return matchesNames.toList();
  }

  bool nameExists(String name) {
    if (_contactNames.contains(name)) {
      return true;
    } else {
      return false;
    }
  }

  /// Strips the phoneNumbers to a plain 10 digit number. All other characters like
  /// +,*,#,(,) etc are removed along with the country code and only a maximum of 10 digit
  /// number is preserved.
  static String stripPhoneNumber(String phoneNumber) {
    phoneNumber =
        phoneNumber.replaceAll(RegExp('[\ \_\+\-\.\,\(\)\/\N\*\#\;]'), "");
    if (phoneNumber.length > 10) {
      // print('stripping size ${phoneNumber.length} $phoneNumber');
      phoneNumber = phoneNumber.substring(phoneNumber.length - 10);
    }
    return phoneNumber;
  }
}

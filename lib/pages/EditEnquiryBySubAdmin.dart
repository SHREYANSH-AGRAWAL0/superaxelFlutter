// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:loginuicolors/models/enquriyModel.dart';
import 'package:loginuicolors/services/subAdminService.dart';
import 'package:loginuicolors/utils/Globals.dart';

class EditEnqSubAdmin extends HookWidget {
  EditEnqSubAdmin({
    Key? key,
  }) : super(key: key);

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final _newOfferedPrice = useTextEditingController();
    final _scrollController = useScrollController();

    Enquiry enqury = ModalRoute.of(context)!.settings.arguments as Enquiry;
    final status = useState('');

    Future<void> updateEnquiry(BuildContext context, Enquiry enq) async {
      if (!_formKey.currentState!.validate()) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fill the new fields')));
        return;
      }
      bool success = await SubAdminService.updateEnquiry(
          body: {'id': enq.id.toString(), 'price': _newOfferedPrice.text.trim().toString(), 'status': status.value});
      if (success) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Enquiry Updated Successfully')));
        Navigator.pop(context);
        Navigator.pushReplacementNamed(context, 'HomeSubAdmin');
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error in updating enquiry')));
      }
    }

    final imageUrls = enqury.imagesUrls.map((e) => e.replaceAll('/..', Globals.restApiUrl)).toList();

    useEffect(() {
      status.value = enqury.status;
      return null;
    }, []);

    return SafeArea(
      child: Scaffold(
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('The id is : ' + enqury.id.toString()),
                Text('The mobile number is : ' + enqury.mobile_number.toString()),
                Text('The address is : ' + enqury.address),
                Text('The guaranted price is : ' + enqury.offered_price),
                Text('The status is: ' + enqury.status),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  controller: _newOfferedPrice,
                  validator: (value) {
                    if (value == null) {
                      return 'Enter some value';
                    }
                    if (value.length > 0) {
                      return null;
                    }
                    return 'Enter valid price';
                  },
                  decoration: InputDecoration(
                    label: Text('Enter the new offered price'),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                DropdownButtonFormField(
                    isDense: true,
                    value: enqury.status,
                    decoration: InputDecoration(
                      labelText: 'Enter the new Status',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'pending',
                        child: Text('pending'),
                      ),
                      DropdownMenuItem(
                        value: 'Out for delivery',
                        child: Text('Out for delivery'),
                      ),
                      DropdownMenuItem(
                        value: 'Delivered',
                        child: Text('Delivered'),
                      ),
                      DropdownMenuItem(
                        value: 'Cancel',
                        child: Text('Cancel'),
                      ),
                    ],
                    onChanged: (value) {
                      debugPrint("value is $value");
                      status.value = value.toString();
                    }),
                const SizedBox(height: 20),
                imageUrls.isEmpty
                    ? const SizedBox.shrink()
                    : Container(
                        padding: const EdgeInsets.only(top: 10.0),
                        height: 200,
                        child: Scrollbar(
                          thumbVisibility: true, //always show scrollbar
                          thickness: 4, //width of scrollbar
                          radius: Radius.circular(20), //corner radius of scrollbar
                          controller: _scrollController,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            controller: _scrollController,
                            itemCount: imageUrls.length,
                            separatorBuilder: (context, index) => Container(
                              height: 20,
                              width: 20,

                              // margin: const EdgeInsets.symmetric(vertical: 10),
                              // child: Column(
                              //   children: [
                              //     Text(
                              //       "Image ${index + 1}",
                              //       style: TextStyle(color: Colors.black, fontSize: 14),
                              //     ),
                              //     const Divider(color: Colors.grey, thickness: 2),
                              //   ],
                              // ),
                            ),
                            itemBuilder: (context, index) {
                              String imageUrl = imageUrls[index].toString().replaceAll('..', '');
                              imageUrl = imageUrl.replaceAll('file://', '');
                              imageUrl = Globals.restApiUrl + imageUrl;
                              return SizedBox(
                                height: 200,
                                width: 200,
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.contain,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      debugPrint("status is ${status.value}");
                      await updateEnquiry(context, enqury);
                    },
                    child: Text('Submit Updates'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

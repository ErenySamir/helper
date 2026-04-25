import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../AddFamilyData/Model/FamilyModel.dart';

class FamilyCard extends StatelessWidget {
  final FamilyDataModel familyItem;
  final VoidCallback onTap;
  final VoidCallback onAddCard;
  final VoidCallback onDelete;

  const FamilyCard({
    Key? key,
    required this.familyItem,
    required this.onTap,
    required this.onAddCard,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 22.0, left: 22, top: 6, bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            gradient: LinearGradient(
              colors: [
                Colors.blue.shade200,
                Colors.blue.shade50,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 8, right: 18, left: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    Text(
                      "   إسم العائلة :  ".tr +
                          (familyItem.fatherName.length > 25
                              ? '${familyItem.fatherName.substring(0, 25)}...'
                              : familyItem.fatherName),
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14.0,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF000047),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_card, color: Color(0xFF000047)),
                      onPressed: onAddCard,
                    ),
                  ],
                ),
                Text(
                  " تاريخ العطية : ".tr +
                      (familyItem.date.length > 30
                          ? '${familyItem.date.substring(0, 30)}...'
                          : familyItem.date),
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14.0,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF000047),
                  ),
                ),
                Text(
                  " العطية : ".tr +
                      (familyItem.give.length > 50
                          ? '${familyItem.give.substring(0, 50)}...'
                          : familyItem.give),
                  textAlign: Get.locale?.languageCode == 'ar'
                      ? TextAlign.right
                      : TextAlign.left,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14.0,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF000047),
                  ),
                ),
                Text(
                  "  اسم المعطي :  ".tr +
                      (familyItem.giverName.length > 30
                          ? '${familyItem.giverName.substring(0, 30)}...'
                          : familyItem.giverName),
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14.0,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF000047),
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
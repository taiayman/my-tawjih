import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taleb_edu_platform/models/mostajadat_modal.dart';
import 'package:taleb_edu_platform/providers/mostajadat_provider.dart';
import 'package:taleb_edu_platform/screens/mostajadat_details_screen.dart';
import 'package:taleb_edu_platform/screens/mostajadat_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class JobsScreen extends ConsumerWidget {
  const JobsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mostajadatAsyncValue = ref.watch(mostajadatProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('jobs_label'.tr(), style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
      ),
      body: mostajadatAsyncValue.when(
        data: (mostajadatList) {
          final jobsMostajadat = mostajadatList.where((m) => m.category == 'jobs').toList(); 
          return ListView.builder(
            itemCount: jobsMostajadat.length,
            itemBuilder: (context, index) {
              final mostajadat = jobsMostajadat[index];
              return MostajadatCard(mostajadat: mostajadat); 
            },
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
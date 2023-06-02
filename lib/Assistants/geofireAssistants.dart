import '../Models/nearbyAvailableMechanic.dart';

class GeoFireAssistant
{
  static List<NearbyAvailableMechanic> nearbyAvailableMechaniclist=[];

  static void removeMechanicFromList(String key)
  {
    int? index;
    index= nearbyAvailableMechaniclist?.indexWhere((element) => element.key==key);
    print("indexx");
    print(index);
    if(index!.isNegative)
      {

      }
    else{
    nearbyAvailableMechaniclist?.removeAt(index!);}
  }
  static void updateMechanicNearbyLocation(NearbyAvailableMechanic Mechanic)
  {

    int index=nearbyAvailableMechaniclist.indexWhere((element) => element.key==Mechanic.key);
    nearbyAvailableMechaniclist[index].longitude=Mechanic.longitude;
    nearbyAvailableMechaniclist[index].latitude=Mechanic.latitude;


  }
}
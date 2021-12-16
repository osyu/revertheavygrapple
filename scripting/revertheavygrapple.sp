#pragma newdecls required
#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <dhooks>

#define PLUGIN_VERSION "1.0.1"

public Plugin myinfo =
{
  name = "[TF2] Revert Heavy Grapple Nerf",
  author = "ugng",
  description = "Re-enable grappling hook jump boost for Heavy",
  version = PLUGIN_VERSION,
  url = "https://osyu.sh/"
}

public void OnPluginStart()
{
  CreateConVar("revertheavygrapple_version", PLUGIN_VERSION, "Revert Heavy Grapple Nerf version", FCVAR_NOTIFY|FCVAR_DONTRECORD);

  StartPrepSDKCall(SDKCall_Static);
  PrepSDKCall_SetSignature(SDKLibrary_Server, "@CreateInterface", 0);
  PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
  PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
  PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);

  Handle hCreateInterface = EndPrepSDKCall();
  Address pGameMovement = SDKCall(hCreateInterface, "GameMovement001", 0);
  hCreateInterface.Close();

  Handle hCfgFile = LoadGameConfigFile("revertheavygrapple");
  int offset = GameConfGetOffset(hCfgFile, "CTFGameMovement::CheckJumpButton");
  hCfgFile.Close();

  Handle hCheckJumpButtonPre = DHookCreate(offset, HookType_Raw, ReturnType_Void, ThisPointer_Address, CheckJumpButtonPre);
  Handle hCheckJumpButtonPost = DHookCreate(offset, HookType_Raw, ReturnType_Void, ThisPointer_Address, CheckJumpButtonPost);
  DHookRaw(hCheckJumpButtonPre, false, pGameMovement);
  DHookRaw(hCheckJumpButtonPost, true, pGameMovement);
}

public MRESReturn CheckJumpButtonPre(Address pThis)
{
  Address classOffset = view_as<Address>(FindSendPropInfo("CTFPlayer", "m_iClass"));
  Address pPlayer = view_as<Address>(LoadFromAddress(pThis + view_as<Address>(4), NumberType_Int32));
  int class = LoadFromAddress(pPlayer + classOffset, NumberType_Int32);

  if (class == 6)
  {
    StoreToAddress(pPlayer + classOffset, 15, NumberType_Int32);
  }

  return MRES_Handled;
}

public MRESReturn CheckJumpButtonPost(Address pThis)
{
  Address classOffset = view_as<Address>(FindSendPropInfo("CTFPlayer", "m_iClass"));
  Address pPlayer = view_as<Address>(LoadFromAddress(pThis + view_as<Address>(4), NumberType_Int32));
  int class = LoadFromAddress(pPlayer + classOffset, NumberType_Int32);

  if (class == 15)
  {
    StoreToAddress(pPlayer + classOffset, 6, NumberType_Int32);
  }

  return MRES_Handled;
}

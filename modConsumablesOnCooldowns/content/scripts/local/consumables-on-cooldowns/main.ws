
function COC_sendRefillCallIfPlayerInventory(inventory: CInventoryComponent) {
  var witcher: W3PlayerWitcher;

  witcher = GetWitcherPlayer();
  
  if(inventory.GetEntity() == witcher) {
    COC_startPotionRefillCooldown();
  }
}

function COC_startPotionRefillCooldown() {
  var i: int;

  // first we look if there already a potion refill timer in progress.
  for (i = 0; i < thePlayer.custom_cooldowns.Size(); i += 1) {
    // if there is a timer we do nothing and leave
    if ((COC_PotionRefillCooldownTimer)thePlayer.custom_cooldowns[i]) {
      return;
    }
  }

  SU_addCustomCooldown(new COC_PotionRefillCooldownTimer in thePlayer);
}

class COC_PotionRefillCooldownTimer extends SU_CooldownTimer {
  default counter_limit = 10; // 60 * 15

  default icon_name = "icons\inventory\scrolls\scroll2.dds";

  function onComplete(): bool {
    COC_refillConsumables();

    if (COC_playerHasConsumablesThatNeedsRefill()) {
      this.injection_time = theGame.GetEngineTimeAsSeconds();

      return false;
    }

    return true;
  }
}

function COC_refillConsumables() {
  var singletonItems: array<SItemUniqueId>;
  var current_item: SItemUniqueId;
  var i: int;

  singletonItems = thePlayer.inv.GetSingletonItems();

  for(i = 0; i < singletonItems.Size(); i += 1) {
    current_item = singletonItems[i];

    if (thePlayer.inv.SingletonItemGetAmmo(current_item) < thePlayer.inv.SingletonItemGetMaxAmmo(current_item)) {
      thePlayer.inv.SingletonItemAddAmmo(current_item, 1);
    }
  }

  theSound.SoundEvent("gui_alchemy_brew");
}

function COC_playerHasConsumablesThatNeedsRefill(): bool {
  var singletonItems: array<SItemUniqueId>;
  var current_item: SItemUniqueId;
  var i: int;

  singletonItems = thePlayer.inv.GetSingletonItems();

  for(i = 0; i < singletonItems.Size(); i += 1) {
    current_item = singletonItems[i];

    if (!thePlayer.inv.IsItemBomb(current_item) && !thePlayer.inv.IsItemPotion(current_item)) {
      continue;
    }

    if (thePlayer.inv.SingletonItemGetAmmo(current_item) < thePlayer.inv.SingletonItemGetMaxAmmo(current_item)) {

      return true;
    }
  }

  return false;
}
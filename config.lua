Config = {}

Config.defaultlang = 'ro_lang'

Config.MaxCarcass = 100

--webhooks place your webhook url between the two '
Config.Webhook = 'https://discord.com/api/webhooks/1223030054137757828/IeGYozZx8AYiXrJwKxDBWuQ9Byf7OzNzY0cMDGjStHsV6uDg82Iv_TFhOeOuKzvTTLJb' --will display when someone opens a chest who did it what items they got what chest etc
Config.WebhookTitle = 'HunterWagon'
Config.WebhookAvatar = 'https://cdn.discordapp.com/attachments/1215063804296306758/1217571513713037312/webhooks.256x228.png?ex=660482d6&is=65f20dd6&hm=4484c2bdde6de17680f53cf6999147f1477694c788fb81b19e77e6add140fb79&'
----------------------------------------------------


Config.PositionPropset = {
    [1] = {-0.30, 0.70, 1.0, 0.0, 0.0, 96.0},
    [2] = {0.30, 0.70, 1.0, 0.0, 0.0, 80.0},
    [3] = {-0.30, -0.20, 1.0, 0.0, 0.0, 75.0},
    [4] = {0.30, -0.20, 1.0, 0.0, 0.0, 60.0},
    [5] = {-0.30, -1.0, 1.0, 0.0, 0.0, 55.0},
    [6] = {0.30, -1.0, 1.0, 0.0, 0.0, 90.0}
}

Config.Textures = {
	['cross'] = {"scoretimer_textures", "scoretimer_generic_cross"},
	['locked'] = {"menu_textures","stamp_locked_rank"},
	['tick'] = {"scoretimer_textures","scoretimer_generic_tick"},
	['money'] = {"inventory_items", "money_moneystack"},
	['alert'] = {"menu_textures", "menu_icon_alert"},
}
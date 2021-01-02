# Copyright 2013 The Android Open Source Project
# Copyright 2019 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

LOCAL_PATH := frameworks/base/data/sounds

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/Alarm_Beep_01.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/alarms/Alarm_Beep_01.ogg \
    $(LOCAL_PATH)/Alarm_Beep_02.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/alarms/Alarm_Beep_02.ogg \
    $(LOCAL_PATH)/Alarm_Beep_03.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/alarms/Alarm_Beep_03.ogg \
    $(LOCAL_PATH)/Alarm_Buzzer.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/alarms/Alarm_Buzzer.ogg \
    $(LOCAL_PATH)/Alarm_Rooster_02.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/alarms/Alarm_Rooster_02.ogg \
    $(LOCAL_PATH)/alarms/ogg/Barium.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/alarms/Barium.ogg \
    $(LOCAL_PATH)/alarms/ogg/Hassium.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/alarms/Hassium.ogg \
    $(LOCAL_PATH)/alarms/ogg/Scandium.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/alarms/Scandium.ogg \
    vendor/lineage/prebuilt/common/media/audio/alarms/Argon-old.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/alarms/Argon-old.ogg \
    vendor/lineage/prebuilt/common/media/audio/alarms/Carbon-old.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/alarms/Carbon-old.ogg \
    vendor/lineage/prebuilt/common/media/audio/alarms/Krypton-old.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/alarms/Krypton-old.ogg \
    vendor/lineage/prebuilt/common/media/audio/alarms/Neon-old.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/alarms/Neon-old.ogg \
    vendor/lineage/prebuilt/common/media/audio/alarms/Osmium-old.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/alarms/Osmium-old.ogg \
    vendor/lineage/prebuilt/common/media/audio/alarms/Oxygen-old.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/alarms/Oxygen-old.ogg \
    vendor/lineage/prebuilt/common/media/audio/alarms/Platinum-old.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/alarms/Platinum-old.ogg

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/F1_New_SMS.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/F1_New_SMS.ogg \
    $(LOCAL_PATH)/newwavelabs/CaffeineSnake.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/CaffeineSnake.ogg \
    $(LOCAL_PATH)/newwavelabs/DearDeer.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/DearDeer.ogg \
    $(LOCAL_PATH)/newwavelabs/DontPanic.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/DontPanic.ogg \
    $(LOCAL_PATH)/newwavelabs/Highwire.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Highwire.ogg \
    $(LOCAL_PATH)/newwavelabs/KzurbSonar.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/KzurbSonar.ogg \
    $(LOCAL_PATH)/newwavelabs/OnTheHunt.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/OnTheHunt.ogg \
    $(LOCAL_PATH)/newwavelabs/Voila.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Voila.ogg \
    $(LOCAL_PATH)/notifications/Aldebaran.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Aldebaran.ogg \
    $(LOCAL_PATH)/notifications/Altair.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Altair.ogg \
    $(LOCAL_PATH)/notifications/Antares.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Antares.ogg \
    $(LOCAL_PATH)/notifications/Beat_Box_Android.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Beat_Box_Android.ogg \
    $(LOCAL_PATH)/notifications/Betelgeuse.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Betelgeuse.ogg \
    $(LOCAL_PATH)/notifications/Canopus.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Canopus.ogg \
    $(LOCAL_PATH)/notifications/Castor.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Castor.ogg \
    $(LOCAL_PATH)/notifications/Cricket.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Cricket.ogg \
    $(LOCAL_PATH)/notifications/Deneb.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Deneb.ogg \
    $(LOCAL_PATH)/notifications/Doink.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Doink.ogg \
    $(LOCAL_PATH)/notifications/Drip.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Drip.ogg \
    $(LOCAL_PATH)/notifications/Electra.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Electra.ogg \
    $(LOCAL_PATH)/notifications/Fomalhaut.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Fomalhaut.ogg \
    $(LOCAL_PATH)/notifications/Heaven.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Heaven.ogg \
    $(LOCAL_PATH)/notifications/Merope.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Merope.ogg \
    $(LOCAL_PATH)/notifications/moonbeam.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/moonbeam.ogg \
    $(LOCAL_PATH)/notifications/ogg/Adara.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Adara.ogg \
    $(LOCAL_PATH)/notifications/ogg/Alya.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Alya.ogg \
    $(LOCAL_PATH)/notifications/ogg/Antimony.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Antimony.ogg \
    $(LOCAL_PATH)/notifications/ogg/Arcturus.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Arcturus.ogg \
    $(LOCAL_PATH)/notifications/ogg/Argon.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Argon.ogg \
    $(LOCAL_PATH)/notifications/ogg/Bellatrix.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Bellatrix.ogg \
    $(LOCAL_PATH)/notifications/ogg/Beryllium.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Beryllium.ogg \
    $(LOCAL_PATH)/notifications/ogg/Capella.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Capella.ogg \
    $(LOCAL_PATH)/notifications/ogg/CetiAlpha.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/CetiAlpha.ogg \
    $(LOCAL_PATH)/notifications/ogg/Cobalt.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Cobalt.ogg \
    $(LOCAL_PATH)/notifications/ogg/Fluorine.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Fluorine.ogg \
    $(LOCAL_PATH)/notifications/ogg/Gallium.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Gallium.ogg \
    $(LOCAL_PATH)/notifications/ogg/Helium.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Helium.ogg \
    $(LOCAL_PATH)/notifications/ogg/Hojus.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Hojus.ogg \
    $(LOCAL_PATH)/notifications/ogg/Iridium.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Iridium.ogg \
    $(LOCAL_PATH)/notifications/ogg/Krypton.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Krypton.ogg \
    $(LOCAL_PATH)/notifications/ogg/Mira.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Mira.ogg \
    $(LOCAL_PATH)/notifications/ogg/Palladium.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Palladium.ogg \
    $(LOCAL_PATH)/notifications/ogg/Polaris.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Polaris.ogg \
    $(LOCAL_PATH)/notifications/ogg/Pollux.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Pollux.ogg \
    $(LOCAL_PATH)/notifications/ogg/Procyon.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Procyon.ogg \
    $(LOCAL_PATH)/notifications/ogg/Proxima.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Proxima.ogg \
    $(LOCAL_PATH)/notifications/ogg/Radon.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Radon.ogg \
    $(LOCAL_PATH)/notifications/ogg/Rubidium.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Rubidium.ogg \
    $(LOCAL_PATH)/notifications/ogg/Selenium.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Selenium.ogg \
    $(LOCAL_PATH)/notifications/ogg/Shaula.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Shaula.ogg \
    $(LOCAL_PATH)/notifications/ogg/Spica.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Spica.ogg \
    $(LOCAL_PATH)/notifications/ogg/Strontium.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Strontium.ogg \
    $(LOCAL_PATH)/notifications/ogg/Syrma.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Syrma.ogg \
    $(LOCAL_PATH)/notifications/ogg/Talitha.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Talitha.ogg \
    $(LOCAL_PATH)/notifications/ogg/Thallium.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Thallium.ogg \
    $(LOCAL_PATH)/notifications/ogg/Upsilon.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Upsilon.ogg \
    $(LOCAL_PATH)/notifications/ogg/Vega.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Vega.ogg \
    $(LOCAL_PATH)/notifications/ogg/Xenon.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Xenon.ogg \
    $(LOCAL_PATH)/notifications/ogg/Zirconium.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Zirconium.ogg \
    $(LOCAL_PATH)/notifications/pixiedust.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/pixiedust.ogg \
    $(LOCAL_PATH)/notifications/pizzicato.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/pizzicato.ogg \
    $(LOCAL_PATH)/notifications/Plastic_Pipe.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Plastic_Pipe.ogg \
    $(LOCAL_PATH)/notifications/regulus.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/regulus.ogg \
    $(LOCAL_PATH)/notifications/sirius.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/sirius.ogg \
    $(LOCAL_PATH)/notifications/Sirrah.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Sirrah.ogg \
    $(LOCAL_PATH)/notifications/TaDa.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/TaDa.ogg \
    $(LOCAL_PATH)/notifications/tweeters.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/tweeters.ogg

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/Ring_Classic_02.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Ring_Classic_02.ogg \
    $(LOCAL_PATH)/Ring_Digital_02.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Ring_Digital_02.ogg \
    $(LOCAL_PATH)/Ring_Synth_02.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Ring_Synth_02.ogg \
    $(LOCAL_PATH)/Ring_Synth_04.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Ring_Synth_04.ogg \
    $(LOCAL_PATH)/newwavelabs/Backroad.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Backroad.ogg \
    $(LOCAL_PATH)/newwavelabs/BeatPlucker.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/BeatPlucker.ogg \
    $(LOCAL_PATH)/newwavelabs/BentleyDubs.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/BentleyDubs.ogg \
    $(LOCAL_PATH)/newwavelabs/Big_Easy.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Big_Easy.ogg \
    $(LOCAL_PATH)/newwavelabs/BirdLoop.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/BirdLoop.ogg \
    $(LOCAL_PATH)/newwavelabs/Bollywood.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Bollywood.ogg \
    $(LOCAL_PATH)/newwavelabs/BussaMove.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/BussaMove.ogg \
    $(LOCAL_PATH)/newwavelabs/Cairo.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Cairo.ogg \
    $(LOCAL_PATH)/newwavelabs/Calypso_Steel.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Calypso_Steel.ogg \
    $(LOCAL_PATH)/newwavelabs/CaribbeanIce.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/CaribbeanIce.ogg \
    $(LOCAL_PATH)/newwavelabs/Champagne_Edition.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Champagne_Edition.ogg \
    $(LOCAL_PATH)/newwavelabs/Club_Cubano.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Club_Cubano.ogg \
    $(LOCAL_PATH)/newwavelabs/CrayonRock.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/CrayonRock.ogg \
    $(LOCAL_PATH)/newwavelabs/CrazyDream.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/CrazyDream.ogg \
    $(LOCAL_PATH)/newwavelabs/CurveBall.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/CurveBall.ogg \
    $(LOCAL_PATH)/newwavelabs/DancinFool.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/DancinFool.ogg \
    $(LOCAL_PATH)/newwavelabs/DonMessWivIt.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/DonMessWivIt.ogg \
    $(LOCAL_PATH)/newwavelabs/DreamTheme.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/DreamTheme.ogg \
    $(LOCAL_PATH)/newwavelabs/Eastern_Sky.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Eastern_Sky.ogg \
    $(LOCAL_PATH)/newwavelabs/Enter_the_Nexus.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Enter_the_Nexus.ogg \
    $(LOCAL_PATH)/newwavelabs/EtherShake.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/EtherShake.ogg \
    $(LOCAL_PATH)/newwavelabs/FriendlyGhost.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/FriendlyGhost.ogg \
    $(LOCAL_PATH)/newwavelabs/Funk_Yall.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Funk_Yall.ogg \
    $(LOCAL_PATH)/newwavelabs/GameOverGuitar.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/GameOverGuitar.ogg \
    $(LOCAL_PATH)/newwavelabs/Gimme_Mo_Town.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Gimme_Mo_Town.ogg \
    $(LOCAL_PATH)/newwavelabs/Glacial_Groove.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Glacial_Groove.ogg \
    $(LOCAL_PATH)/newwavelabs/Growl.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Growl.ogg \
    $(LOCAL_PATH)/newwavelabs/HalfwayHome.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/HalfwayHome.ogg \
    $(LOCAL_PATH)/newwavelabs/InsertCoin.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/InsertCoin.ogg \
    $(LOCAL_PATH)/newwavelabs/LoopyLounge.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/LoopyLounge.ogg \
    $(LOCAL_PATH)/newwavelabs/LoveFlute.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/LoveFlute.ogg \
    $(LOCAL_PATH)/newwavelabs/MidEvilJaunt.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/MidEvilJaunt.ogg \
    $(LOCAL_PATH)/newwavelabs/Nairobi.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Nairobi.ogg \
    $(LOCAL_PATH)/newwavelabs/Nassau.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Nassau.ogg \
    $(LOCAL_PATH)/newwavelabs/NewPlayer.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/NewPlayer.ogg \
    $(LOCAL_PATH)/newwavelabs/Noises2.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Noises2.ogg \
    $(LOCAL_PATH)/newwavelabs/Noises3.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Noises3.ogg \
    $(LOCAL_PATH)/newwavelabs/No_Limits.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/No_Limits.ogg \
    $(LOCAL_PATH)/newwavelabs/OrganDub.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/OrganDub.ogg \
    $(LOCAL_PATH)/newwavelabs/Paradise_Island.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Paradise_Island.ogg \
    $(LOCAL_PATH)/newwavelabs/Playa.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Playa.ogg \
    $(LOCAL_PATH)/newwavelabs/Revelation.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Revelation.ogg \
    $(LOCAL_PATH)/newwavelabs/Road_Trip.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Road_Trip.ogg \
    $(LOCAL_PATH)/newwavelabs/RomancingTheTone.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/RomancingTheTone.ogg \
    $(LOCAL_PATH)/newwavelabs/Safari.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Safari.ogg \
    $(LOCAL_PATH)/newwavelabs/Savannah.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Savannah.ogg \
    $(LOCAL_PATH)/newwavelabs/Seville.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Seville.ogg \
    $(LOCAL_PATH)/newwavelabs/Shes_All_That.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Shes_All_That.ogg \
    $(LOCAL_PATH)/newwavelabs/SilkyWay.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/SilkyWay.ogg \
    $(LOCAL_PATH)/newwavelabs/SitarVsSitar.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/SitarVsSitar.ogg \
    $(LOCAL_PATH)/newwavelabs/SpringyJalopy.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/SpringyJalopy.ogg \
    $(LOCAL_PATH)/newwavelabs/Steppin_Out.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Steppin_Out.ogg \
    $(LOCAL_PATH)/newwavelabs/Terminated.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Terminated.ogg \
    $(LOCAL_PATH)/newwavelabs/Third_Eye.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Third_Eye.ogg \
    $(LOCAL_PATH)/newwavelabs/Thunderfoot.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Thunderfoot.ogg \
    $(LOCAL_PATH)/newwavelabs/TwirlAway.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/TwirlAway.ogg \
    $(LOCAL_PATH)/newwavelabs/VeryAlarmed.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/VeryAlarmed.ogg \
    $(LOCAL_PATH)/newwavelabs/World.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/World.ogg \
    $(LOCAL_PATH)/ringtones/BOOTES.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/BOOTES.ogg \
    $(LOCAL_PATH)/ringtones/CASSIOPEIA.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/CASSIOPEIA.ogg \
    $(LOCAL_PATH)/ringtones/Eridani.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Eridani.ogg \
    $(LOCAL_PATH)/ringtones/FreeFlight.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/FreeFlight.ogg \
    $(LOCAL_PATH)/ringtones/Lyra.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Lyra.ogg \
    $(LOCAL_PATH)/ringtones/ogg/Andromeda.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Andromeda.ogg \
    $(LOCAL_PATH)/ringtones/ogg/Aquila.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Aquila.ogg \
    $(LOCAL_PATH)/ringtones/ogg/ArgoNavis.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/ArgoNavis.ogg \
    $(LOCAL_PATH)/ringtones/ogg/CanisMajor.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/CanisMajor.ogg \
    $(LOCAL_PATH)/ringtones/ogg/Carina.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Carina.ogg \
    $(LOCAL_PATH)/ringtones/ogg/Centaurus.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Centaurus.ogg \
    $(LOCAL_PATH)/ringtones/ogg/Cygnus.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Cygnus.ogg \
    $(LOCAL_PATH)/ringtones/ogg/Draco.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Draco.ogg \
    $(LOCAL_PATH)/ringtones/ogg/Girtab.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Girtab.ogg \
    $(LOCAL_PATH)/ringtones/ogg/Hydra.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Hydra.ogg \
    $(LOCAL_PATH)/ringtones/ogg/Kuma.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Kuma.ogg \
    $(LOCAL_PATH)/ringtones/ogg/Machina.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Machina.ogg \
    $(LOCAL_PATH)/ringtones/ogg/Orion.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Orion.ogg \
    $(LOCAL_PATH)/ringtones/ogg/Pegasus.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Pegasus.ogg \
    $(LOCAL_PATH)/ringtones/ogg/Perseus.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Perseus.ogg \
    $(LOCAL_PATH)/ringtones/ogg/Pyxis.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Pyxis.ogg \
    $(LOCAL_PATH)/ringtones/ogg/Rasalas.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Rasalas.ogg \
    $(LOCAL_PATH)/ringtones/ogg/Rigel.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Rigel.ogg \
    $(LOCAL_PATH)/ringtones/ogg/Scarabaeus.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Scarabaeus.ogg \
    $(LOCAL_PATH)/ringtones/ogg/Sceptrum.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Sceptrum.ogg \
    $(LOCAL_PATH)/ringtones/ogg/Solarium.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Solarium.ogg \
    $(LOCAL_PATH)/ringtones/ogg/Themos.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Themos.ogg \
    $(LOCAL_PATH)/ringtones/ogg/UrsaMinor.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/UrsaMinor.ogg \
    $(LOCAL_PATH)/ringtones/ogg/Zeta.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Zeta.ogg \
    $(LOCAL_PATH)/ringtones/Testudo.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Testudo.ogg \
    $(LOCAL_PATH)/ringtones/Vespa.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Vespa.ogg

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/effects/ogg/ChargingStarted.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/ChargingStarted.ogg \
    $(LOCAL_PATH)/effects/ogg/Effect_Tick_48k.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ui/Effect_Tick.ogg \
    $(LOCAL_PATH)/effects/material/ogg/WirelessChargingStarted.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/WirelessChargingStarted.ogg

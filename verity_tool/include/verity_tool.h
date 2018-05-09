/*
 * Copyright (C) 2018 The LineageOS Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#pragma once

#include <string>

/*
 * Return codes:
 *
 *    true: verity state set
 *    false: verity state not set
 */
bool set_block_device_verity_enabled(const std::string& block_device,
                                     bool enable);

/*
 * Return codes:
 *
 *    true: verity state set for all block devices
 *    false: verity state not for set all block devices
 */
bool set_verity_enabled(bool enable);

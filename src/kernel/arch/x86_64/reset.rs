/*
 * Copyright (c) 2014 Arcterus@mail.com
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */ 

pub unsafe fn immediate_reset() {
	asm!("xor %eax, %eax; lidt $0; int3" :: "m" (0 as *u64));
}

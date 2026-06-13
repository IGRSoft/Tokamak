// Copyright 2024 Tokamak contributors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#ifndef TOKAMAK_CRUNTIME_H
#define TOKAMAK_CRUNTIME_H

#include <stddef.h>
#include <stdint.h>

/// Forward declaration of the Swift runtime's mangled-name type lookup.
///
/// Tokamak's reflection layer resolves a struct's stored-property types from their
/// mangled names. Referencing the reserved `swift_*` runtime symbol directly from
/// Swift (via `@_silgen_name`) is now diagnosed by the compiler ("this will become an
/// error"). Declaring the entry point here and calling it through C interop keeps the
/// symbol reference in C — where it links against libswiftCore's stable, C-ABI export —
/// which silences that diagnostic without changing behavior.
///
/// Mirrors the runtime's `extern "C"` export (pointer/`size_t` ABI only):
///   const Metadata *swift_getTypeByMangledNameInContext(
///       const char *typeNameStart, size_t typeNameLength,
///       const ContextDescriptor *context, const void * const *genericArgs);
const void *_Nullable swift_getTypeByMangledNameInContext(
    const uint8_t *_Nullable typeNameStart,
    size_t typeNameLength,
    const void *_Nullable genericContext,
    const void *_Nullable const *_Nullable genericArguments);

#endif /* TOKAMAK_CRUNTIME_H */

const windows = @import("windows.zig");
const w32 = windows;
const IUnknown = windows.IUnknown;
const UINT = windows.UINT;
const UINT32 = windows.UINT32;
const HRESULT = windows.HRESULT;
const ULONG = windows.ULONG;
const DWORD = windows.DWORD;
const WINAPI = windows.WINAPI;
const GUID = windows.GUID;
const LPCWSTR = windows.LPCWSTR;
const BYTE = windows.BYTE;
const LONGLONG = windows.LONGLONG;
const PROPVARIANT = windows.PROPVARIANT;

// 0x0002 for Windows 7+
pub const SDK_VERSION = 0x0002;
pub const API_VERSION = 0x0070;
pub const VERSION = (SDK_VERSION << 16 | API_VERSION);

pub const SOURCE_READER_INVALID_STREAM_INDEX = 0xffffffff;
pub const SOURCE_READER_ALL_STREAMS = 0xfffffffe;
pub const SOURCE_READER_ANY_STREAM = 0xfffffffe;
pub const SOURCE_READER_FIRST_AUDIO_STREAM = 0xfffffffd;
pub const SOURCE_READER_FIRST_VIDEO_STREAM = 0xfffffffc;
pub const SOURCE_READER_MEDIASOURCE = 0xffffffff;

pub const SOURCE_READER_FLAG = packed struct(UINT32) {
    ERROR: bool = false,
    END_OF_STREAM: bool = false,
    NEW_STREAM: bool = false,
    __unused3: bool = false,
    NATIVE_MEDIA_TYPE_CHANGED: bool = false,
    CURRENT_MEDIA_TYPE_CHANGED: bool = false,
    __unused6: bool = false,
    __unused7: bool = false,
    STREAM_TICK: bool = false,
    ALL_EFFECTS_REMOVED: bool = false,
    __unused: u22 = 0,
};

pub const SOURCE_READER_CONTROL_FLAG = packed struct(UINT32) {
    DRAIN: bool = false,
    __unused: u31 = 0,
};

pub extern "mfplat" fn MFStartup(version: ULONG, flags: DWORD) callconv(WINAPI) HRESULT;
pub extern "mfplat" fn MFShutdown() callconv(WINAPI) HRESULT;
pub extern "mfplat" fn MFCreateAttributes(attribs: **IAttributes, init_size: UINT32) callconv(WINAPI) HRESULT;

pub extern "mfreadwrite" fn MFCreateSourceReaderFromURL(
    url: LPCWSTR,
    attribs: ?*IAttributes,
    reader: **ISourceReader,
) callconv(WINAPI) HRESULT;

pub const IAttributes = extern struct {
    __v: *const VTable,

    pub usingnamespace Methods(@This());

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub usingnamespace IUnknown.Methods(T);

            pub inline fn GetUINT32(self: *T, guid: *const GUID, value: *UINT32) HRESULT {
                return @ptrCast(*const IAttributes.VTable, self.__v).GetUINT32(
                    @ptrCast(*IAttributes, self),
                    guid,
                    value,
                );
            }
            pub inline fn GetGUID(self: *T, key: *const GUID, value: *GUID) HRESULT {
                return @ptrCast(*const IAttributes.VTable, self.__v)
                    .GetGUID(@ptrCast(*IAttributes, self), key, value);
            }
            pub inline fn SetUINT32(self: *T, guid: *const GUID, value: UINT32) HRESULT {
                return @ptrCast(*const IAttributes.VTable, self.__v)
                    .SetUINT32(@ptrCast(*IAttributes, self), guid, value);
            }
            pub inline fn SetGUID(self: *T, key: *const GUID, value: *const GUID) HRESULT {
                return @ptrCast(*const IAttributes.VTable, self.__v)
                    .SetGUID(@ptrCast(*IAttributes, self), key, value);
            }
            pub inline fn SetUnknown(self: *T, guid: *const GUID, unknown: ?*IUnknown) HRESULT {
                return @ptrCast(*const IAttributes.VTable, self.__v)
                    .SetUnknown(@ptrCast(*IAttributes, self), guid, unknown);
            }
        };
    }

    pub const VTable = extern struct {
        base: IUnknown.VTable,
        GetItem: *anyopaque,
        GetItemType: *anyopaque,
        CompareItem: *anyopaque,
        Compare: *anyopaque,
        GetUINT32: *const fn (*IAttributes, *const GUID, *UINT32) callconv(WINAPI) HRESULT,
        GetUINT64: *anyopaque,
        GetDouble: *anyopaque,
        GetGUID: *const fn (*IAttributes, *const GUID, *GUID) callconv(WINAPI) HRESULT,
        GetStringLength: *anyopaque,
        GetString: *anyopaque,
        GetAllocatedString: *anyopaque,
        GetBlobSize: *anyopaque,
        GetBlob: *anyopaque,
        GetAllocatedBlob: *anyopaque,
        GetUnknown: *anyopaque,
        SetItem: *anyopaque,
        DeleteItem: *anyopaque,
        DeleteAllItems: *anyopaque,
        SetUINT32: *const fn (*IAttributes, *const GUID, UINT32) callconv(WINAPI) HRESULT,
        SetUINT64: *anyopaque,
        SetDouble: *anyopaque,
        SetGUID: *const fn (*IAttributes, *const GUID, *const GUID) callconv(WINAPI) HRESULT,
        SetString: *anyopaque,
        SetBlob: *anyopaque,
        SetUnknown: *const fn (*IAttributes, *const GUID, ?*IUnknown) callconv(WINAPI) HRESULT,
        LockStore: *anyopaque,
        UnlockStore: *anyopaque,
        GetCount: *anyopaque,
        GetItemByIndex: *anyopaque,
        CopyAllItems: *anyopaque,
    };
};

pub const IMediaEvent = extern struct {
    __v: *const VTable,

    pub usingnamespace Methods(@This());

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub usingnamespace IAttributes.Methods(T);

            pub inline fn GetType(self: *T, met: *MediaEventType) HRESULT {
                return @ptrCast(*const IMediaEvent.VTable, self.__v)
                    .GetType(@ptrCast(*IMediaEvent, self), met);
            }
            pub inline fn GetExtendedType(self: *T, ex_met: *GUID) HRESULT {
                return @ptrCast(*const IMediaEvent.VTable, self.__v)
                    .GetExtendedType(@ptrCast(*IMediaEvent, self), ex_met);
            }
            pub inline fn GetStatus(self: *T, status: *HRESULT) HRESULT {
                return @ptrCast(*const IMediaEvent.VTable, self.__v)
                    .GetStatus(@ptrCast(*IMediaEvent, self), status);
            }
            pub inline fn GetValue(self: *T, value: *PROPVARIANT) HRESULT {
                return @ptrCast(*const IMediaEvent.VTable, self.__v)
                    .GetValue(@ptrCast(*IMediaEvent, self), value);
            }
        };
    }

    pub const VTable = extern struct {
        base: IAttributes.VTable,
        GetType: *const fn (*IMediaEvent, *MediaEventType) callconv(WINAPI) HRESULT,
        GetExtendedType: *const fn (*IMediaEvent, *GUID) callconv(WINAPI) HRESULT,
        GetStatus: *const fn (*IMediaEvent, *HRESULT) callconv(WINAPI) HRESULT,
        GetValue: *const fn (*IMediaEvent, *PROPVARIANT) callconv(WINAPI) HRESULT,
    };
};

pub const ISourceReader = extern struct {
    __v: *const VTable,

    pub usingnamespace Methods(@This());

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub usingnamespace IUnknown.Methods(T);

            pub inline fn GetNativeMediaType(
                self: *T,
                stream_index: DWORD,
                media_type_index: DWORD,
                media_type: **IMediaType,
            ) HRESULT {
                return @ptrCast(*const ISourceReader.VTable, self.__v).GetNativeMediaType(
                    @ptrCast(*ISourceReader, self),
                    stream_index,
                    media_type_index,
                    media_type,
                );
            }
            pub inline fn GetCurrentMediaType(
                self: *T,
                stream_index: DWORD,
                media_type: **IMediaType,
            ) HRESULT {
                return @ptrCast(*const ISourceReader.VTable, self.__v)
                    .GetCurrentMediaType(@ptrCast(*ISourceReader, self), stream_index, media_type);
            }
            pub inline fn SetCurrentMediaType(
                self: *T,
                stream_index: DWORD,
                reserved: ?*DWORD,
                media_type: *IMediaType,
            ) HRESULT {
                return @ptrCast(*const ISourceReader.VTable, self.__v)
                    .SetCurrentMediaType(@ptrCast(*ISourceReader, self), stream_index, reserved, media_type);
            }
            pub inline fn ReadSample(
                self: *T,
                stream_index: DWORD,
                control_flags: SOURCE_READER_CONTROL_FLAG,
                actual_stream_index: ?*DWORD,
                stream_flags: ?*SOURCE_READER_FLAG,
                timestamp: ?*LONGLONG,
                sample: ?*?*ISample,
            ) HRESULT {
                return @ptrCast(*const ISourceReader.VTable, self.__v).ReadSample(
                    @ptrCast(*ISourceReader, self),
                    stream_index,
                    control_flags,
                    actual_stream_index,
                    stream_flags,
                    timestamp,
                    sample,
                );
            }
            pub inline fn SetCurrentPosition(self: *T, guid: *const GUID, prop: *const PROPVARIANT) HRESULT {
                return @ptrCast(*const ISourceReader.VTable, self.__v)
                    .SetCurrentPosition(@ptrCast(*ISourceReader, self), guid, prop);
            }
        };
    }

    pub const VTable = extern struct {
        base: IUnknown.VTable,
        GetStreamSelection: *anyopaque,
        SetStreamSelection: *anyopaque,
        GetNativeMediaType: *const fn (*ISourceReader, DWORD, DWORD, **IMediaType) callconv(WINAPI) HRESULT,
        GetCurrentMediaType: *const fn (*ISourceReader, DWORD, **IMediaType) callconv(WINAPI) HRESULT,
        SetCurrentMediaType: *const fn (*ISourceReader, DWORD, ?*DWORD, *IMediaType) callconv(WINAPI) HRESULT,
        SetCurrentPosition: *const fn (*ISourceReader, *const GUID, *const PROPVARIANT) callconv(WINAPI) HRESULT,
        ReadSample: *const fn (
            *ISourceReader,
            DWORD,
            SOURCE_READER_CONTROL_FLAG,
            ?*DWORD,
            ?*SOURCE_READER_FLAG,
            ?*LONGLONG,
            ?*?*ISample,
        ) callconv(WINAPI) HRESULT,
        Flush: *anyopaque,
        GetServiceForStream: *anyopaque,
        GetPresentationAttribute: *anyopaque,
    };
};

pub const IMediaType = extern struct {
    __v: *const VTable,

    pub usingnamespace Methods(@This());

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub usingnamespace IAttributes.Methods(T);
        };
    }

    pub const VTable = extern struct {
        base: IAttributes.VTable,
        GetMajorType: *anyopaque,
        IsCompressedFormat: *anyopaque,
        IsEqual: *anyopaque,
        GetRepresentation: *anyopaque,
        FreeRepresentation: *anyopaque,
    };
};

pub const ISample = extern struct {
    __v: *const VTable,

    pub usingnamespace Methods(@This());

    fn Methods(comptime T: type) type {
        return extern struct {
            pub usingnamespace IAttributes.Methods(T);

            pub inline fn ConvertToContiguousBuffer(self: *T, buffer: **IMediaBuffer) HRESULT {
                return @ptrCast(*const ISample.VTable, self.__v)
                    .ConvertToContiguousBuffer(@ptrCast(*ISample, self), buffer);
            }
            pub inline fn GetBufferByIndex(self: *T, index: DWORD, buffer: **IMediaBuffer) HRESULT {
                return @ptrCast(*const ISample.VTable, self.__v)
                    .GetBufferByIndex(@ptrCast(*ISample, self), index, buffer);
            }
        };
    }

    pub const VTable = extern struct {
        base: IAttributes.VTable,
        GetSampleFlags: *anyopaque,
        SetSampleFlags: *anyopaque,
        GetSampleTime: *anyopaque,
        SetSampleTime: *anyopaque,
        GetSampleDuration: *anyopaque,
        SetSampleDuration: *anyopaque,
        GetBufferCount: *anyopaque,
        GetBufferByIndex: *const fn (*ISample, DWORD, **IMediaBuffer) callconv(WINAPI) HRESULT,
        ConvertToContiguousBuffer: *const fn (*ISample, **IMediaBuffer) callconv(WINAPI) HRESULT,
        AddBuffer: *anyopaque,
        RemoveBufferByIndex: *anyopaque,
        RemoveAllBuffers: *anyopaque,
        GetTotalLength: *anyopaque,
        CopyToBuffer: *anyopaque,
    };
};

pub const IMediaBuffer = extern struct {
    __v: *const VTable,

    pub usingnamespace Methods(@This());

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub usingnamespace IUnknown.Methods(T);

            pub inline fn Lock(self: *T, ptr: *[*]BYTE, max_len: ?*DWORD, current_len: ?*DWORD) HRESULT {
                return @ptrCast(*const IMediaBuffer.VTable, self.__v)
                    .Lock(@ptrCast(*IMediaBuffer, self), ptr, max_len, current_len);
            }
            pub inline fn Unlock(self: *T) HRESULT {
                return @ptrCast(*const IMediaBuffer.VTable, self.__v).Unlock(@ptrCast(*IMediaBuffer, self));
            }
            pub inline fn GetCurrentLength(self: *T, length: *DWORD) HRESULT {
                return @ptrCast(*const IMediaBuffer.VTable, self.__v)
                    .GetCurrentLength(@ptrCast(*IMediaBuffer, self), length);
            }
        };
    }

    pub const VTable = extern struct {
        base: IUnknown.VTable,
        Lock: *const fn (*IMediaBuffer, *[*]BYTE, ?*DWORD, ?*DWORD) callconv(WINAPI) HRESULT,
        Unlock: *const fn (*IMediaBuffer) callconv(WINAPI) HRESULT,
        GetCurrentLength: *const fn (*IMediaBuffer, *DWORD) callconv(WINAPI) HRESULT,
        SetCurrentLength: *anyopaque,
        GetMaxLength: *anyopaque,
    };
};

pub const MediaEventType = DWORD;

pub const IID_ISourceReaderCallback = GUID.parse("{deec8d99-fa1d-4d82-84c2-2c8969944867}");
pub const ISourceReaderCallback = extern struct {
    __v: *const VTable,

    pub usingnamespace Methods(@This());

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub usingnamespace IUnknown.Methods(T);

            pub inline fn OnReadSample(
                self: *T,
                status: HRESULT,
                stream_index: DWORD,
                stream_flags: SOURCE_READER_FLAG,
                timestamp: LONGLONG,
                sample: ?*ISample,
            ) HRESULT {
                return @ptrCast(*const ISourceReaderCallback.VTable, self.__v).OnReadSample(
                    @ptrCast(*ISourceReaderCallback, self),
                    status,
                    stream_index,
                    stream_flags,
                    timestamp,
                    sample,
                );
            }
            pub inline fn OnFlush(self: *T, stream_index: DWORD) HRESULT {
                return @ptrCast(*const ISourceReaderCallback.VTable, self.__v)
                    .OnFlush(@ptrCast(*ISourceReaderCallback, self), stream_index);
            }
            pub inline fn OnEvent(self: *T, stream_index: DWORD, event: *IMediaEvent) HRESULT {
                return @ptrCast(*const ISourceReaderCallback.VTable, self.__v)
                    .OnEvent(@ptrCast(*ISourceReaderCallback, self), stream_index, event);
            }
        };
    }

    pub const VTable = extern struct {
        base: IUnknown.VTable,

        OnReadSample: *const fn (
            *ISourceReaderCallback,
            HRESULT,
            DWORD,
            SOURCE_READER_FLAG,
            LONGLONG,
            ?*ISample,
        ) callconv(WINAPI) HRESULT,

        OnFlush: *const fn (*ISourceReaderCallback, DWORD) callconv(WINAPI) HRESULT = onFlushDef,

        OnEvent: *const fn (*ISourceReaderCallback, DWORD, *IMediaEvent) callconv(WINAPI) HRESULT = onEventDef,
    };

    fn onFlushDef(_: *ISourceReaderCallback, _: DWORD) callconv(WINAPI) HRESULT {
        return w32.S_OK;
    }
    fn onEventDef(_: *ISourceReaderCallback, _: DWORD, _: *IMediaEvent) callconv(WINAPI) HRESULT {
        return w32.S_OK;
    }
};

pub const LOW_LATENCY = GUID.parse("{9C27891A-ED7A-40e1-88E8-B22727A024EE}"); // {UINT32 (BOOL)}
pub const SOURCE_READER_ASYNC_CALLBACK = GUID.parse("{1e3dbeac-bb43-4c35-b507-cd644464c965}"); // {*IUnknown}

pub const MT_MAJOR_TYPE = GUID.parse("{48eba18e-f8c9-4687-bf11-0a74c9f96a8f}"); // {GUID}
pub const MT_SUBTYPE = GUID.parse("{f7e34c9a-42e8-4714-b74b-cb29d72c35e5}"); // {GUID}

pub const MT_AUDIO_BITS_PER_SAMPLE = GUID.parse("{f2deb57f-40fa-4764-aa33-ed4f2d1ff669}"); // {UINT32}
pub const MT_AUDIO_SAMPLES_PER_SECOND = GUID.parse("{5faeeae7-0290-4c31-9e8a-c534f68d9dba}"); // {UINT32}
pub const MT_AUDIO_NUM_CHANNELS = GUID.parse("{37e48bf5-645e-4c5b-89de-ada9e29b696a}"); // {UINT32}
pub const MT_AUDIO_BLOCK_ALIGNMENT = GUID.parse("{322de230-9eeb-43bd-ab7a-ff412251541d}"); // {UINT32}
pub const MT_AUDIO_AVG_BYTES_PER_SECOND = GUID.parse("{1aab75c8-cfef-451c-ab95-ac034b8e1731}"); // {UINT32}
pub const MT_ALL_SAMPLES_INDEPENDENT = GUID.parse("{c9173739-5e56-461c-b713-46fb995cb95f}"); // {UINT32 (BOOL)}

pub const AudioFormat_Base = GUID.parse("{00000000-0000-0010-8000-00aa00389b71}");
pub const AudioFormat_PCM = GUID.parse("{00000001-0000-0010-8000-00aa00389b71}");
pub const AudioFormat_Float = GUID.parse("{00000003-0000-0010-8000-00aa00389b71}");

pub const MediaType_Audio = GUID.parse("{73647561-0000-0010-8000-00aa00389b71}");

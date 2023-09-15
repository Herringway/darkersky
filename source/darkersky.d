module darkersky;

import std.stdio;
import std.typecons;

import easyhttp;
import siryul;

struct Request {
	string key;
	double latitude;
	double longitude;
	Excludable[] exclude;
	Language lang;
	Units units;
}

struct Result {
	double latitude;
	double longitude;
	string timezone;
	@Optional Nullable!DataPoint currently;
	@Optional Nullable!DataBlock minutely;
	@Optional Nullable!DataBlock hourly;
	@Optional Nullable!DataBlock daily;
	@Optional Alert[] alerts;
	@Optional Nullable!Flags flags;
}

struct DataBlock {
	DataPoint[] data;
	string summary;
	string icon;
}

struct DataPoint {
	@Optional Nullable!double apparentTemperature;
	@Optional Nullable!double apparentTemperatureHigh;
	@Optional Nullable!Timestamp apparentTemperatureHighTime;
	@Optional Nullable!double apparentTemperatureLow;
	@Optional Nullable!Timestamp apparentTemperatureLowTime;
	@Optional Nullable!double apparentTemperatureMax;
	@Optional Nullable!Timestamp apparentTemperatureMaxTime;
	@Optional Nullable!double apparentTemperatureMin;
	@Optional Nullable!Timestamp apparentTemperatureMinTime;
	@Optional Nullable!double cloudCover;
	@Optional Nullable!double dewPoint;
	@Optional Nullable!double humidty;
	@Optional string icon;
	@Optional Nullable!double moonPhase;
	@Optional Nullable!double nearestStormBearing;
	@Optional Nullable!double nearestStormDistance;
	@Optional Nullable!double ozone;
	@Optional Nullable!double precipAccumulation;
	@Optional Nullable!double precipIntensity;
	@Optional Nullable!double precipIntensityError;
	@Optional Nullable!double precipIntensityMax;
	@Optional Nullable!Timestamp precipIntensityMaxTime;
	@Optional Nullable!double precipProbability;
	@Optional Nullable!Precipitation precipType;
	@Optional Nullable!double pressure;
	@Optional string summary;
	@Optional Nullable!Timestamp sunriseTime;
	@Optional Nullable!Timestamp sunsetTime;
	@Optional Nullable!double temperature;
	@Optional Nullable!double temperatureHigh;
	@Optional Nullable!Timestamp temperatureHighTime;
	@Optional Nullable!double temperatureLow;
	@Optional Nullable!Timestamp temperatureLowTime;
	@Optional Nullable!double temperatureMin;
	@Optional Nullable!Timestamp temperatureMinTime;
	@Optional Nullable!double temperatureMax;
	@Optional Nullable!Timestamp temperatureMaxTime;
	@Optional Nullable!Timestamp time;
	@Optional Nullable!double uvIndex;
	@Optional Nullable!Timestamp uvIndexTime;
	@Optional Nullable!double visibility;
	@Optional Nullable!double windBearing;
	@Optional Nullable!double windGust;
	@Optional Nullable!Timestamp windGustTime;
	@Optional Nullable!double windSpeed;
}

struct Timestamp {
	import std.datetime : hnsecs, SysTime, UTC;
	SysTime val;
	SysTime toSiryulType_() const @safe {
		return toSiryulType!();
	}
	SysTime toSiryulType()() const @safe {
		return val;
	}
	static Timestamp fromSiryulType()(double val) @safe {
		auto timestamp = SysTime.fromUnixTime(cast(long)val, UTC());
		timestamp.fracSecs = (cast(long)((val - cast(long)val) * 10_000_000)).hnsecs;
		return Timestamp(timestamp);
	}
}

struct Alert {
	string description;
	Timestamp expires;
	string[] regions;
	Timestamp time;
	string title;
	string uri;
}

struct Flags {
	//@SiryulizeAs("darksky-unavailable") @Optional void darkskyUnavailable;
	@SiryulizeAs("nearest-station") double nearestStation;
	string[] sources;
	string units;
}


enum Precipitation {
	none,
	rain,
	snow,
	sleet,
}

enum Severity {
	advisory,
	watch,
	warning,
}

enum Excludable {
	currently = "currently",
	minutely = "minutely",
	hourly = "hourly",
	daily = "daily",
	alerts = "alerts",
	flags = "flags",
}

enum Units {
	automatic = "auto",
	canadian = "ca",
	unitedKingdom = "uk2",
	american = "us",
	si = "si",
}

enum Language {
	english = "en",
	arabic = "ar",
	azerbaijani = "az",
	belarusian = "be",
	bulgarian = "bg",
	bengali = "bn",
	bosnian = "bs",
	catalan = "ca",
	czech = "cs",
	danish = "da",
	german = "de",
	greek = "el",
	esperanto = "eo",
	spanish = "es",
	estonian = "et",
	finnish = "fi",
	french = "fr",
	hebrew = "he",
	hindi = "hi",
	croatian = "hr",
	hungarian = "hu",
	indonesian = "id",
	icelandic = "is",
	italian = "it",
	japanese = "ja",
	georgian = "ka",
	kannada = "kn",
	korean = "ko",
	cornish = "kw",
	latvian = "lv",
	malayam = "ml",
	marathi = "mr",
	norwegianBokmål = "nb",
	dutch = "nl",
	punjabi = "pa",
	polish = "pl",
	portuguese = "pt",
	romanian = "ro",
	russian = "ru",
	slovak = "sk",
	slovenian = "sl",
	serbian = "sr",
	swedish = "sv",
	tamil = "ta",
	telugu = "te",
	tetum = "tet",
	turkish = "tr",
	ukrainian = "uk",
	urdu = "ur",
	pigLatin = "x-pig-latin",
	chinese = "zh",
	traditionalChinese = "zh-tw",
}

debug enum baseURL = URL("https://dev.pirateweather.net/forecast/");
else enum baseURL = URL("https://api.pirateweather.net/forecast/");

Result getWeatherForecast(Request request) @safe {
	import std.algorithm.iteration : map;
	import std.exception : enforce;
	import std.string : join;
	enforce(request.key.length > 0, "No key specified");
	string[string] params;
	params["lang"] = cast(string)request.lang;
	if (request.exclude.length > 0) {
		params["exclude"] = request.exclude.map!(x => cast(string)x).join(",");
	}
	params["units"] = cast(string)request.units;
	const url = baseURL.absoluteURL!"%s/%.10s,%.10s"(request.key, request.latitude, request.longitude).withReplacedParams(params);
	return get(url, ["x-api-key": request.key]).content.fromString!(Result, JSON);
}

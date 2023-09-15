import darkersky;
import herrconf;
import siryul;

import std;

void main() {
	Request req;
	req.longitude = herringwayConfig.location.longitude;
	req.latitude = herringwayConfig.location.latitude;
	req.units = Units.canadian;
	req.key = "pn3wJgCWFLooUrG818mi7pbLRajpizsUDCpeMDa0";
	auto forecast = getWeatherForecast(req);
	writeln(forecast.toString!(YAML, Siryulize.omitNulls));
}
#!/bin/bash
# Generates the BehaviorSpace experiment XML and parameter CSV
# from environment variables. Intended to run inside the container
# before the NetLogo model is launched.
#
# All parameters default to baseline values from parameters_baseline.csv.
# Only override the ones you need to change via environment variables.

set -euo pipefail

OUTPUT_DIR="${1:-parameters}"
PARAM_CSV="${OUTPUT_DIR}/generated_parameters.csv"
EXPERIMENT_XML="${OUTPUT_DIR}/generated_experiment.xml"

mkdir -p "${OUTPUT_DIR}"

# --- Baseline defaults (from parameters_baseline.csv) ---

: "${MODEL_OUTPUT_DIR:=outputs}"
: "${SSP:=2.6}"
: "${ENSEMBLE_RUNS:=30}"
: "${START_YEAR:=1956}"
: "${SAVE_YEAR:=2001}"
: "${PROJECTION_YEAR:=2024}"
: "${SEARCH_YEAR:=9999}"
: "${END_YEAR:=2075}"
: "${START_CATCHMENT_RESTORE:=9999}"
: "${RESTORE_TIMEFRAME:=0}"
: "${START_COTS_CONTROL:=9999}"
: "${ECO_THRESHOLD_HA:=7.6}"
: "${COTS_THRESHOLD:=99999}"
: "${CORAL_THRESHOLD:=0}"
: "${COTS_VESSELS_GBR:=0}"
: "${COTS_VESSELS_FN:=0}"
: "${COTS_VESSELS_N:=0}"
: "${COTS_VESSELS_C:=0}"
: "${COTS_VESSELS_S:=0}"
: "${COTS_VESSELS_SECTOR:=0}"
: "${INTERVENE_LON_MIN:=140}"
: "${INTERVENE_LON_MAX:=155}"
: "${INTERVENE_LAT_MIN:=-25}"
: "${INTERVENE_LAT_MAX:=-9}"
: "${START_MODIFIED_ZONING:=9999}"
: "${REZONED_REEFS:=0}"
: "${START_MODIFIED_FISHING:=9999}"
: "${CATCH_REDUCTION:=0}"
: "${START_LOWER_SIZELIMIT:=9999}"
: "${START_UPPER_SIZELIMIT:=9999}"
: "${START_COTSLIMIT:=9999}"
: "${START_EMPEROR_RELEASE:=9999}"
: "${RELEASE_REEFS:=0}"
: "${RELEASE_THRESHOLD:=0}"
: "${RELEASE_NUMBER:=0}"
: "${START_REGIONAL_SHADING:=9999}"
: "${REGIONAL_SHADING_REDUCTION:=0}"
: "${START_RUBBLE_CONSOLIDATION:=9999}"
: "${CONSOLIDATION_REEFS:=0}"
: "${CONSOLIDATION_THRESHOLD:=0}"
: "${CONSOLIDATION_HECTARES:=0}"
: "${START_CORAL_SEEDING:=9999}"
: "${SEED_REEFS:=0}"
: "${SEED_THRESHOLD:=0}"
: "${SEED_HECTARES:=0}"
: "${HYBRID_FRACTION:=0}"
: "${DOMINANCE:=0}"
: "${START_CORAL_SLICK:=9999}"
: "${SLICK_REEFS:=0}"
: "${SLICK_THRESHOLD:=0}"
: "${SLICK_HECTARES:=0}"
: "${START_REEF_SHADING:=9999}"
: "${SHADING_REEFS:=0}"
: "${REEF_SHADING_REDUCTION:=0}"
: "${START_PH_PROTECTION:=9999}"
: "${PH_REEFS:=0}"
: "${PH_PROTECTION:=0}"

# --- Generate the parameter CSV ---
cat > "${PARAM_CSV}" <<CSV
Variable name,Value,Description,Units,Format or range
MODEL_OUTPUT_DIR,${MODEL_OUTPUT_DIR},Output directory for model results,N/A,"1.9 2.6 4.5 7.0 8.5"
SSP,${SSP},Climate scenario,N/A,"1.9 2.6 4.5 7.0 8.5"
ensemble-runs,${ENSEMBLE_RUNS},Number of runs in ensemble,N/A,[1 100]
start-year,${START_YEAR},First year of each run,year,YYYY
save-year,${SAVE_YEAR},First year saved to output file,year,YYYY
projection-year,${PROJECTION_YEAR},First year of future projection,year,YYYY
search-year,${SEARCH_YEAR},First year used to find high benefit reefs,year,YYYY
end-year,${END_YEAR},YYYY
start-catchment-restore,${START_CATCHMENT_RESTORE},First year of catchment restoration,year,YYYY
restore-timeframe,${RESTORE_TIMEFRAME},Time-scale for catchment restoration,years,[5 25]
start-CoTS-control,${START_COTS_CONTROL},YYYY
eco-threshold-ha,${ECO_THRESHOLD_HA},Minimum CoTS concentration at site to apply control,CoTS per ha,[1 15]
CoTS-threshold,${COTS_THRESHOLD},Maximum CoTS concentration at reef to apply control,CoTS per ha,[200 99999]
coral-threshold,${CORAL_THRESHOLD},Minimum average coral cover at reef to apply control,N/A,[0 1]
CoTS-vessels-GBR,${COTS_VESSELS_GBR},CoTS vessels across GBR,vessels,[0 9]
CoTS-vessels-FN,${COTS_VESSELS_FN},CoTS vessels in Far-northern Region,vessels,[0 9]
CoTS-vessels-N,${COTS_VESSELS_N},CoTS vessels in Northern Region,vessels,[0 9]
CoTS-vessels-C,${COTS_VESSELS_C},CoTS vessels in Central Region,vessels,[0 9]
CoTS-vessels-S,${COTS_VESSELS_S},CoTS vessels in Southern Region,vessels,[0 9]
CoTS-vessels-sector,${COTS_VESSELS_SECTOR},CoTS vessels in AIMS sector with most CoTS,vessels,[0 9]
intervene-lon-min,${INTERVENE_LON_MIN},Minimum longitude of interventions,Degrees longitude,[140 155]
intervene-lon-max,${INTERVENE_LON_MAX},Maximum longitude of interventions,Degrees longitude,[140 155]
intervene-lat-min,${INTERVENE_LAT_MIN},Minimum latitude of interventions,Degrees latitude,[-25 -9]
intervene-lat-max,${INTERVENE_LAT_MAX},Maximum latitude of interventions,Degrees latitude,[-25 -9]
start-modified-zoning,${START_MODIFIED_ZONING},First year applying enhanced zoning,year,YYYY
rezoned-reefs,${REZONED_REEFS},Number of reefs with zoning enhanced,reefs,[0 2700]
start-modified-fishing,${START_MODIFIED_FISHING},First year applying modified fishing,year,YYYY
catch-reduction,${CATCH_REDUCTION},Proportional change in modified catches,N/A,[0 2]
start-lower-sizelimit,${START_LOWER_SIZELIMIT},First year applying lower size limits on catches,year,YYYY
start-upper-sizelimit,${START_UPPER_SIZELIMIT},First year applying upper size limits on catches,year,YYYY
start-CoTSlimit,${START_COTSLIMIT},First year excluding fishing from active outbreak reefs,year,YYYY
start-emperor-release,${START_EMPEROR_RELEASE},Emperor release start year,year,N/A
release-reefs,${RELEASE_REEFS},Number of reefs where emperors are released,reefs,N/A
release-threshold,${RELEASE_THRESHOLD},Maximum existing stock of adult emperors for release,emperors per ha,N/A
release-number,${RELEASE_NUMBER},Number of juvenile emperors released per reef,emperors per ha,N/A
start-regional-shading,${START_REGIONAL_SHADING},First year regional shading,year,N/A
regional-shading-reduction,${REGIONAL_SHADING_REDUCTION},DHW reduction due to regional shading,DHW,N/A
start-rubble-consolidation,${START_RUBBLE_CONSOLIDATION},First year consolidating rubble,year,N/A
consolidation-reefs,${CONSOLIDATION_REEFS},Number of reefs consolidated per year,reefs,N/A
consolidation-threshold,${CONSOLIDATION_THRESHOLD},Minimum rubble threshold for consolidation,N/A,[0 1]
consolidation-hectares,${CONSOLIDATION_HECTARES},Total annual consolidated area,ha,N/A
start-coral-seeding,${START_CORAL_SEEDING},First year seeding thermally tolerant corals,year,N/A
seed-reefs,${SEED_REEFS},Number of reefs seeded per year,reefs,N/A
seed-threshold,${SEED_THRESHOLD},Maximum coral cover threshold for seeding,N/A,[0 1]
seed-hectares,${SEED_HECTARES},Total annual seeded area,ha,N/A
hybrid-fraction,${HYBRID_FRACTION},Fraction of staghorn acropora able to hybridise,N/A,[0 1]
dominance,${DOMINANCE},Dominance of thermally tolerant corals,N/A,[0 1]
start-coral-slick,${START_CORAL_SLICK},First year releasing coral slicks,year,N/A
slick-reefs,${SLICK_REEFS},Number of reefs with slicks released per year,reefs,N/A
slick-threshold,${SLICK_THRESHOLD},Maximum coral threshold for release of slicks,N/A,[0 1]
slick-hectares,${SLICK_HECTARES},Total annual area of slicks,ha,N/A
start-reef-shading,${START_REEF_SHADING},First year of reef shading,year,N/A
shading-reefs,${SHADING_REEFS},Number of reefs shaded per year,reefs,N/A
reef-shading-reduction,${REEF_SHADING_REDUCTION},DHW reduction due to shading,DHW,N/A
start-pH-protection,${START_PH_PROTECTION},First year of pH treatment,year,YYYY
pH-reefs,${PH_REEFS},Number of reefs treated per year,reefs,N/A
pH-protection,${PH_PROTECTION},Protection from ocean acidification,N/A,[0 1]
CSV

echo "Generated parameter CSV: ${PARAM_CSV}"

# --- Generate the BehaviorSpace experiment XML ---
cat > "${EXPERIMENT_XML}" <<XML
<?xml version='1.0' encoding='UTF-8'?>
<!DOCTYPE experiments SYSTEM "behaviorspace.dtd">
<experiments>
    <experiment name="HeadlessRun" repetitions="1" runMetricsEveryStep="false">
        <setup>setup</setup>
        <go>go</go>
        <timeLimit steps="1000" />
        <enumeratedValueSet variable="parameter-filename">
            <value value="&quot;${PARAM_CSV}&quot;" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="output-filename">
            <value value="&quot;${MODEL_OUTPUT_DIR}/output.csv&quot;" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="SSP">
            <value value="${SSP}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="ensemble-runs">
            <value value="${ENSEMBLE_RUNS}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="start-year">
            <value value="${START_YEAR}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="save-year">
            <value value="${SAVE_YEAR}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="projection-year">
            <value value="${PROJECTION_YEAR}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="search-year">
            <value value="${SEARCH_YEAR}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="end-year">
            <value value="${END_YEAR}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="start-catchment-restore">
            <value value="${START_CATCHMENT_RESTORE}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="restore-timeframe">
            <value value="${RESTORE_TIMEFRAME}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="start-CoTS-control">
            <value value="${START_COTS_CONTROL}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="CoTS-threshold">
            <value value="${COTS_THRESHOLD}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="coral-threshold">
            <value value="${CORAL_THRESHOLD}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="CoTS-vessels-GBR">
            <value value="${COTS_VESSELS_GBR}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="CoTS-vessels-FN">
            <value value="${COTS_VESSELS_FN}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="CoTS-vessels-N">
            <value value="${COTS_VESSELS_N}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="CoTS-vessels-C">
            <value value="${COTS_VESSELS_C}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="CoTS-vessels-S">
            <value value="${COTS_VESSELS_S}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="CoTS-vessels-sector">
            <value value="${COTS_VESSELS_SECTOR}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="intervene-lon-min">
            <value value="${INTERVENE_LON_MIN}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="intervene-lon-max">
            <value value="${INTERVENE_LON_MAX}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="intervene-lat-min">
            <value value="${INTERVENE_LAT_MIN}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="intervene-lat-max">
            <value value="${INTERVENE_LAT_MAX}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="start-modified-zoning">
            <value value="${START_MODIFIED_ZONING}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="rezoned-reefs">
            <value value="${REZONED_REEFS}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="start-modified-fishing">
            <value value="${START_MODIFIED_FISHING}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="catch-reduction">
            <value value="${CATCH_REDUCTION}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="start-lower-sizelimit">
            <value value="${START_LOWER_SIZELIMIT}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="start-upper-sizelimit">
            <value value="${START_UPPER_SIZELIMIT}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="start-CoTSlimit">
            <value value="${START_COTSLIMIT}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="start-emperor-release">
            <value value="${START_EMPEROR_RELEASE}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="release-reefs">
            <value value="${RELEASE_REEFS}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="release-threshold">
            <value value="${RELEASE_THRESHOLD}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="release-number">
            <value value="${RELEASE_NUMBER}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="start-regional-shading">
            <value value="${START_REGIONAL_SHADING}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="regional-shading-reduction">
            <value value="${REGIONAL_SHADING_REDUCTION}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="start-rubble-consolidation">
            <value value="${START_RUBBLE_CONSOLIDATION}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="consolidation-reefs">
            <value value="${CONSOLIDATION_REEFS}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="consolidation-threshold">
            <value value="${CONSOLIDATION_THRESHOLD}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="consolidation-hectares">
            <value value="${CONSOLIDATION_HECTARES}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="start-coral-seeding">
            <value value="${START_CORAL_SEEDING}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="seed-reefs">
            <value value="${SEED_REEFS}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="seed-threshold">
            <value value="${SEED_THRESHOLD}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="seed-hectares">
            <value value="${SEED_HECTARES}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="hybrid-fraction">
            <value value="${HYBRID_FRACTION}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="dominance">
            <value value="${DOMINANCE}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="start-coral-slick">
            <value value="${START_CORAL_SLICK}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="slick-reefs">
            <value value="${SLICK_REEFS}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="slick-threshold">
            <value value="${SLICK_THRESHOLD}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="slick-hectares">
            <value value="${SLICK_HECTARES}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="start-reef-shading">
            <value value="${START_REEF_SHADING}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="shading-reefs">
            <value value="${SHADING_REEFS}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="reef-shading-reduction">
            <value value="${REEF_SHADING_REDUCTION}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="start-pH-protection">
            <value value="${START_PH_PROTECTION}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="pH-reefs">
            <value value="${PH_REEFS}" />
        </enumeratedValueSet>
        <enumeratedValueSet variable="pH-protection">
            <value value="${PH_PROTECTION}" />
        </enumeratedValueSet>
    </experiment>
</experiments>
XML

echo "Generated experiment XML: ${EXPERIMENT_XML}"

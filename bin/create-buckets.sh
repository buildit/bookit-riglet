#!/bin/bash

echo "Create Foundation S3 bucket: rig.${NAME_SUFFIX}.${PROJECT}.${REGION}.foundation"
aws s3api head-bucket --bucket "rig.${NAME_SUFFIX}.${PROJECT}.${REGION}.foundation" --region "${REGION}" ||
  aws s3 mb s3://rig.${NAME_SUFFIX}.${PROJECT}.${REGION}.foundation  --region "${REGION}" # Foundation configs
aws s3api put-bucket-versioning --bucket "rig.${NAME_SUFFIX}.${PROJECT}.${REGION}.foundation" --versioning-configuration Status=Enabled --region "${REGION}"

echo "Create InfraDev S3 bucket: rig.${NAME_SUFFIX}.${PROJECT}.${REGION}.infradev"
aws s3api head-bucket --bucket "rig.${NAME_SUFFIX}.${PROJECT}.${REGION}.infradev" --region "${REGION}" ||
  aws s3 mb s3://rig.${NAME_SUFFIX}.${PROJECT}.${REGION}.infradev --region "${REGION}" # Storage for InfraDev
aws s3api put-bucket-versioning --bucket "rig.${NAME_SUFFIX}.${PROJECT}.${REGION}.infradev" --versioning-configuration Status=Enabled --region "${REGION}"

echo "Create Build Artifacts S3 bucket: rig.${NAME_SUFFIX}.${PROJECT}.${REGION}.build"
aws s3api head-bucket --bucket "rig.${NAME_SUFFIX}.${PROJECT}.${REGION}.build" --region "${REGION}" ||
  aws s3 mb s3://rig.${NAME_SUFFIX}.${PROJECT}.${REGION}.build --region "${REGION}" # Build artifacts, etc
aws s3api put-bucket-versioning --bucket "rig.${NAME_SUFFIX}.${PROJECT}.${REGION}.build" --versioning-configuration Status=Enabled --region "${REGION}"

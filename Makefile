.PHONY: install
UNAME := $(shell uname)
ifeq ($(UNAME),Linux)
	TERRAFORM_URL="https://releases.hashicorp.com/terraform/0.11.6/terraform_0.11.6_linux_amd64.zip"
endif
ifeq ($(UNAME),Darwin)
	TERRAFORM_URL="https://releases.hashicorp.com/terraform/0.11.6/terraform_0.11.6_darwin_amd64.zip"
endif
TERRAFORM_LOCATION:=/usr/local/bin/terraform

define create
    rm -rf server/*_override.tf
    cp -f ./server-override/$(1)_override.tf ./server || :
    terraform init -backend=true -backend-config='$(2)/backend.config' $(2)
	terraform workspace select $(1) $(2) || (terraform workspace new $(1) $(2))
	terraform apply -auto-approve -var 'environment=$(1)' $(2);
endef

define graph
	terraform init -backend=true -backend-config='$(2)/backend.config' $(2)
	terraform workspace select $(1) $(2) || (terraform workspace new $(1) $(2))
	terraform graph -draw-cycles -type plan $(2) | dot -Tpng > $(1).png;
endef

define plan
    rm -rf server/*_override.tf
    cp -f ./server-override/$(1)_override.tf ./server || :
	terraform init -backend=true -backend-config='$(2)/backend.config' $(2)
	terraform workspace select $(1) $(2) || (terraform workspace new $(1) $(2))
	terraform plan -var 'environment=$(1)' $(2);
endef

define create_staging_from_prod
    rm -rf server/*_override.tf
    cp -f ./server-override/from_$(2)_override.tf ./server || :
    terraform init -backend=true -backend-config='$(3)/backend.config' $(3)
	terraform workspace select $(2) $(3) || (terraform workspace new $(2) $(3))
	terraform apply -auto-approve -var 'environment=$(2)' -var 'fromDB=$(1)' $(3);
endef

define destroy
    rm -rf server/*_override.tf
    cp -f ./server-override/$(1)_override.tf ./server || :
    terraform init -backend=true -backend-config='$(2)/backend.config' $(2)
	terraform workspace select $(1) $(2) || (terraform workspace new $(1) $(2))
	terraform destroy -var 'environment=$(1)' $(2);
endef

unencrypt:
	@openssl aes-256-cbc -a -md md5 -in server/key/openchs-infra.pem.enc -d -out server/key/openchs-infra.pem -k ${ENCRYPTION_KEY_AWS}

install:
	rm -rf terraform terraform.zip
	curl -L $(TERRAFORM_URL) > terraform.zip
	unzip terraform.zip
	rm -rf terraform.zip
	-sudo mv terraform $(TERRAFORM_LOCATION)
	make unencrypt

staging-create:
	$(call create,staging,server)

staging-app-create:
	$(call create,app.staging,client)

staging-destroy:
	$(call destroy,staging,server)

production-destroy:
	$(call destroy,prod,server)

staging-plan:
	$(call plan,staging,server)

staging-app-plan:
	$(call plan,app.staging,client)

production-plan:
	$(call plan,prod,server)

production-create:
	$(call create,prod,server)

staging-graph:
	$(call graph,staging,server)

demo-create:
	$(call create,demo,server)

demo-plan:
	$(call plan,demo,server)

demo-graph:
	$(call graph,demo,server)

demo-destroy:
	$(call destroy,demo,server)

uat-create:
	$(call create,uat,server)

uat-plan:
	$(call plan,uat,server)

uat-graph:
	$(call graph,uat,server)

uat-destroy:
	$(call destroy,uat,server)

reporting-create:
	$(call create,reporting,reporting)

reporting-plan:
	$(call plan,reporting,reporting)

reporting-graph:
	$(call graph,reporting,reporting)

reporting-destroy:
	$(call graph,reporting,reporting)

staging-create-from-prod: staging-destroy
	$(call create_staging_from_prod,uat,staging,server)

# Generate the AUTH_HASH using basic authentication in Postman using generate code for cUrl (using your bintray user and password)
# Number range in start and end
delete-bintray-version:
	number=$(start) ; while [[ $$number -le $(end) ]] ; do \
		curl -X DELETE \
              https://api.bintray.com/packages/openchs/rpm/OpenCHS/versions/$$number \
              -H 'Authorization: Basic $(AUTH_HASH)' \
              -H 'Cache-Control: no-cache' \
              -H 'Postman-Token: 6b0484b6-eda4-4151-9aab-c33ef114994e' ; \
		((number = number + 1)) ; \
	done

# AWS Environment variables are set which will authenticate you
create-users:
	cd user-management && python create_users.py $(pool)
migrate-users:
	aws cognito-idp list-users --user-pool-id $(pool) > cognito-users.json
	node user-management/mapUsers.js > cognito-users-mapped.json
	curl -X POST http://localhost:8021/users -d @cognito-users-mapped.json -H "Content-Type: application/json" -H "AUTH-TOKEN: $(token)"
delete-user-attributes:
	aws cognito-idp admin-delete-user-attributes --user-pool-id $(pool) --username test --user-attribute-names "custom:organisationId" "custom:isAdmin" "custom:organisationName" "custom:isOrganisationAdmin" "custom:isUser" "custom:catchmentId"
add-user-attribute:
#	aws cognito-idp add-custom-attributes --user-pool-id $(pool) --custom-attributes Name=userUUID,AttributeDataType=String,Mutable=true
#	aws cognito-idp admin-update-user-attributes --username test --user-pool-id $(pool) --user-attributes Name=custom:userUUID,Value=e011d56f-19dd-41ff-9eeb-521b37affa74
	aws cognito-idp admin-update-user-attributes --username admin --user-pool-id $(pool) --user-attributes Name=custom:userUUID,Value=5fed2907-df3a-4867-aef5-c87f4c78a31a
	aws cognito-idp admin-update-user-attributes --username ck-demo --user-pool-id $(pool) --user-attributes Name=custom:userUUID,Value=d36cb738-c9a7-462e-9f12-1021ed4d1065
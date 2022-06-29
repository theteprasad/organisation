 provider "aws" {
  region  = "ap-south-1"
  profile = "default"
}
 resource "aws_organizations_organizational_unit" "OU" {
  name      = "Core Learning"
  parent_id = "r-upd7"                                           
 }

############
resource "aws_organizations_account" "account" {
   name  = "Core Governance-1"
  email = "theteprasad111@gmail.com"
  parent_id = aws_organizations_organizational_unit.OU.id
 } 

data "aws_iam_policy_document" "access_cloudtrail" {
statement{
        sid = "cloudtrail"
        actions = ["cloudtrail:*", "config:*", "cloudwatch:*", "cloudfront:*", "sns:*"]
        resources = ["*"]
        effect = "Allow"
    }
}
resource "aws_organizations_policy" "cloudtrail_policy" {
  name        = "governance"
   content     = data.aws_iam_policy_document.access_cloudtrail.json
}
resource "aws_organizations_policy_attachment" "attachtment-1" {
  policy_id = aws_organizations_policy.cloudtrail_policy.id
  target_id = aws_organizations_account.account.id
}

################
 resource "aws_organizations_account" "account1" {
   name  = "Core account share services"
  email = "theteprasad112@gmail.com"
  parent_id = aws_organizations_organizational_unit.OU.id
 }


data "aws_iam_policy_document" "core_prod_shared" {
statement{
        sid = "CoreProdShared"
        actions = ["codepipeline:*", "ram:*"]
        resources = ["*"]
        effect = "Allow"
    }
}
resource "aws_organizations_policy" "core_prod_shared_policy" {
  name        = "CoreProdSharedServices"
   content     = data.aws_iam_policy_document.core_prod_shared.json
}
resource "aws_organizations_policy_attachment" "attachtment-12" {
  policy_id = aws_organizations_policy.core_prod_shared_policy.id
  target_id = aws_organizations_account.account1.id
}

###############
 resource "aws_organizations_account" "account2" {
   name  = "Core account network"
  email = "theteprasad113@gmail.com"
  parent_id = aws_organizations_organizational_unit.OU.id
 }

data "aws_iam_policy_document" "core_prod_network" {
statement{
        sid = "CoreProdNetwork"
        actions = ["cloudfront:*", "route53:*", "cloudformation:*"]
        resources = ["*"]
        effect = "Allow"
    },
      {
            sid = "AllowPublicHostedZonePermissions",
            effect = "Allow",
            action = [
                "route53:CreateHostedZone",
                "route53:UpdateHostedZoneComment",
                "route53:GetHostedZone",
                "route53:ListHostedZones",
                "route53:DeleteHostedZone",
                "route53:ChangeResourceRecordSets",
                "route53:ListResourceRecordSets",
                "route53:GetHostedZoneCount",
                "route53:ListHostedZonesByName"
            ],
            resource = "*"
        },
        {
          sid = "AllowHealthCheckPermissions",
            effect = "Allow",
            action = [
                "route53:CreateHealthCheck",
                "route53:UpdateHealthCheck",
                "route53:GetHealthCheck",
                "route53:ListHealthChecks",
                "route53:DeleteHealthCheck",
                "route53:GetCheckerIpRanges",
                "route53:GetHealthCheckCount",
                "route53:GetHealthCheckStatus",
                "route53:GetHealthCheckLastFailureReason"
            ],
            resource = "*"
        }
    
}
resource "aws_organizations_policy" "core_prod_network_policy" {
  name        = "core_network"
   content     = data.aws_iam_policy_document.core_prod_network.json
}
resource "aws_organizations_policy_attachment" "attachtment-11" {
  policy_id = aws_organizations_policy.core_prod_network_policy.id
  target_id = aws_organizations_account.account2.id
}


#################
 resource "aws_organizations_account" "account3" {
   name  = "Core complience"
  email = "theteprasad114@gmail.com"
  parent_id = aws_organizations_organizational_unit.OU.id
 }

#########
#Child OU

 resource "aws_organizations_organizational_unit" "OU-Prod" {
  name      = "Prod"
  parent_id = aws_organizations_organizational_unit.OU.id
 }

 resource "aws_organizations_account" "account-prod" {
   name  = "Core Prod"
  email = "theteprasad115@gmail.com"
  parent_id = aws_organizations_organizational_unit.OU-Prod.id
 }

data "aws_iam_policy_document" "core_prod" {
statement{
        sid = "CoreProd"
        actions = ["cloudfront:*", "route53:*", "autoscaling-plans:*","sns:*", "cloudwatch:*"]
        resources = ["*"]
        effect = "Allow"
    }
}
resource "aws_organizations_policy" "core_prod_policy" {
  name        = "core_prod"
   content     = data.aws_iam_policy_document.core_prod.json
}
resource "aws_organizations_policy_attachment" "attachtment-10" {
  policy_id = aws_organizations_policy.core_prod_policy.id
  target_id = aws_organizations_account.account-prod.id
}


#Sub OU of Prod

 resource "aws_organizations_organizational_unit" "OU-Prod-1" {
  name      = "Workload"
  parent_id = aws_organizations_organizational_unit.OU-Prod.id
 }

 resource "aws_organizations_account" "account-prod-1" {
   name  = "Core Prod workload account"
  email = "theteprasad116@gmail.com"
  parent_id = aws_organizations_organizational_unit.OU-Prod-1.id
 }


data "aws_iam_policy_document" "workload" {
statement{
        sid = "Workload"
        actions = ["apigateway:*", "lambda:*", "ec2:*", "tag:*",
        "s3:GetBucketVersioning",
        "acm:ListCertificates",
        "acm:ListTagsForCertificate",
        "sns:*",
        "sqs:"]
        resources = ["*"]
        effect = "Allow"
    }
}
resource "aws_organizations_policy" "workload_policy" {
  name        = "Workload"
   content     = data.aws_iam_policy_document.workload.json
}
resource "aws_organizations_policy_attachment" "attachtment-9" {
  policy_id = aws_organizations_policy.workload_policy.id
  target_id = aws_organizations_account.account-prod-1.id
}

#Sub OU of Prod storage

 resource "aws_organizations_organizational_unit" "OU-Prod-2" {
  name      = "Storage"
  parent_id = aws_organizations_organizational_unit.OU-Prod.id
 }

 resource "aws_organizations_account" "account-prod-2" {
   name  = "Core Prod Storage account"
  email = "theteprasad117@gmail.com"
  parent_id = aws_organizations_organizational_unit.OU-Prod-2.id
 }

data "aws_iam_policy_document" "storage" {
statement{
        sid = "Storage"
        actions = [ "elasticfilesystem:*", "s3:*", "fsx:*", "dynamodb:*", "ec2:DescribeVpcs"]
        resources = ["*"]
        effect = "Allow"
    }
}
resource "aws_organizations_policy" "storage_policy" {
  name        = "storage"
   content     = data.aws_iam_policy_document.storage.json
}
resource "aws_organizations_policy_attachment" "attachtment-8" {
  policy_id = aws_organizations_policy.storage_policy.id
  target_id = aws_organizations_account.account-prod-2.id
}


# Sub OU of Prod Security

 resource "aws_organizations_organizational_unit" "OU-Prod-3" {
  name      = "Security"
  parent_id = aws_organizations_organizational_unit.OU-Prod.id
 }

 resource "aws_organizations_account" "account-prod-3" {
   name  = "Core Prod Security account"
  email = "theteprasad118@gmail.com"
  parent_id = aws_organizations_organizational_unit.OU-Prod-3.id
 }

data "aws_iam_policy_document" "user_auth"{
statement{
        sid = "Security"
        actions = [ "iam:*", "cognito-identity:*", "secretsmanager:*", "kms:*", "cognito-idp:*", "cognito-sync:*"]
        resources = ["*"]
        effect = "Allow"
    }
}
resource "aws_organizations_policy" "user_auth_policy" {
  name        = "user_auth"
   content     = data.aws_iam_policy_document.user_auth.json
}
resource "aws_organizations_policy_attachment" "attachtment-7" {
  policy_id = aws_organizations_policy.user_auth_policy.id
  target_id = aws_organizations_account.account-prod-3.id
}

#################################



 resource "aws_organizations_organizational_unit" "OU-NonProd" {
  name      = "NonProd"
  parent_id = aws_organizations_organizational_unit.OU.id
 }

 resource "aws_organizations_account" "account-nonprod" {
   name  = "Audit Account"
  email = "theteprasad119@gmail.com"
  parent_id = aws_organizations_organizational_unit.OU-NonProd.id
 }

data "aws_iam_policy_document" "nonprod_audit" {
statement{
        sid = "CoreProdAccount"
        actions = ["sns:*", "cloudwatch:*"]
        resources = ["*"]
        effect = "Allow"
    }
}
resource "aws_organizations_policy" "nonprod_audit_policy" {
  name        = "CoreNonProdAudit"
   content     = data.aws_iam_policy_document.nonprod_audit.json
}
resource "aws_organizations_policy_attachment" "attachtment-6" {
  policy_id = aws_organizations_policy.nonprod_audit_policy.id
  target_id = aws_organizations_account.account-nonprod.id
}


###################
resource "aws_organizations_account" "account-nonprod-1" {
   name  = "Network Account"
  email = "theteprasad120@gmail.com"
  parent_id = aws_organizations_organizational_unit.OU-NonProd.id
 }

data "aws_iam_policy_document" "core_nonprod" {
statement{
        sid = "CoreNonProdNetwork"
        actions = ["route53:*", "autoscaling-plans:*"]
        resources = ["*"]
        effect = "Allow"
    }
}
resource "aws_organizations_policy" "core_nonprod_policy" {
  name        = "CoreNonProdNetwork"
   content     = data.aws_iam_policy_document.core_nonprod.json
}
resource "aws_organizations_policy_attachment" "attachtment-5" {
  policy_id = aws_organizations_policy.core_nonprod_policy.id
  target_id = aws_organizations_account.account-nonprod-1.id
}
# Sub OU of NonProd Security

 resource "aws_organizations_organizational_unit" "OU-NonProd-1" {
  name      = "Security"
  parent_id = aws_organizations_organizational_unit.OU-NonProd.id
 }

 resource "aws_organizations_account" "account-nonprod-2" {
   name  = "Core Prod Security account"
  email = "theteprasad121@gmail.com"
  parent_id = aws_organizations_organizational_unit.OU-NonProd-1.id
 }


resource "aws_organizations_policy_attachment" "attachtment-4" {
  policy_id = aws_organizations_policy.user_auth_policy.id
  target_id = aws_organizations_account.account-nonprod-2.id
}

#Sub OU of NonProd storage

 resource "aws_organizations_organizational_unit" "OU-NonProd-2" {
  name      = "Storage"
  parent_id = aws_organizations_organizational_unit.OU-NonProd.id
 }

 resource "aws_organizations_account" "account-nonprod-3" {
   name  = "Core Non Prod Storage account"
  email = "theteprasad122@gmail.com"
  parent_id = aws_organizations_organizational_unit.OU-NonProd-2.id
 }

resource "aws_organizations_policy_attachment" "attachtment-3" {
  policy_id = aws_organizations_policy.storage_policy.id
  target_id = aws_organizations_account.account-nonprod-3.id
}

#Sub OU of NonProd

 resource "aws_organizations_organizational_unit" "OU-NonProd-4" {
  name      = "Workload"
  parent_id = aws_organizations_organizational_unit.OU-NonProd.id
 }

 resource "aws_organizations_account" "account-nonprod-4" {
   name  = "Core Prod workload account"
  email = "theteprasad123@gmail.com"
  parent_id = aws_organizations_organizational_unit.OU-NonProd-4.id
 }


resource "aws_organizations_policy_attachment" "attachtment-2" {
  policy_id = aws_organizations_policy.workload_policy.id
  target_id = aws_organizations_account.account-nonprod-4.id
}


#####################


 resource "aws_organizations_organizational_unit" "OU-Exceptions" {
  name      = "Exceptions"
  parent_id = aws_organizations_organizational_unit.OU.id
 }

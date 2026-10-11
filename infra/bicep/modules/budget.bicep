// =============================================================================
//  Budget module — resource-group scoped cost budget with email alerts.
//  Cost-governance guardrail for the lab subscription.
// =============================================================================

metadata name = 'AKS baseline budget'
metadata description = 'Resource-group scoped consumption budget with threshold alerts.'

@description('Required. Budget name.')
param budgetName string

@description('Optional. Monthly budget amount in the billing currency.')
param monthlyBudgetAmount int = 1000

@description('Optional. Email addresses notified when thresholds are crossed.')
param budgetAlertEmails array = []

@description('Optional. Budget start date (first of month, yyyy-MM-dd). Defaults to the first of the current month.')
param startDate string = '${utcNow('yyyy-MM')}-01'

resource budget 'Microsoft.Consumption/budgets@2023-11-01' = {
  name: budgetName
  properties: {
    category: 'Cost'
    amount: monthlyBudgetAmount
    timeGrain: 'Monthly'
    timePeriod: {
      startDate: startDate
    }
    notifications: empty(budgetAlertEmails) ? {} : {
      Actual_GreaterThan_80_Percent: {
        enabled: true
        operator: 'GreaterThan'
        threshold: 80
        contactEmails: budgetAlertEmails
        thresholdType: 'Actual'
      }
      Forecasted_GreaterThan_100_Percent: {
        enabled: true
        operator: 'GreaterThan'
        threshold: 100
        contactEmails: budgetAlertEmails
        thresholdType: 'Forecasted'
      }
    }
  }
}

@description('Budget resource ID.')
output budgetResourceId string = budget.id

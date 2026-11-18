/**
 * ohosTest 测试入口
 */
import conditionEvaluatorTest from './ConditionEvaluator.test';
import ruleEngineTest from './RuleEngine.test';
import defaultDataTest from './DefaultData.test';

export default function testsuite() {
  conditionEvaluatorTest();
  ruleEngineTest();
  defaultDataTest();
}

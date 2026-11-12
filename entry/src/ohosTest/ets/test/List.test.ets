/**
 * ohosTest 测试入口
 */
import { describe, it, expect, beforeAll } from '@ohos/hypium';
import conditionEvaluatorTest from './ConditionEvaluator.test';
import ruleEngineTest from './RuleEngine.test';
import defaultDataTest from './DefaultData.test';

export default function testsuite() {
  conditionEvaluatorTest();
  ruleEngineTest();
  defaultDataTest();
}

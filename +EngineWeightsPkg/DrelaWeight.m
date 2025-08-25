function [Weng] = DrelaWeight(Engine)

lb_N = 4.44822;
BPR = Engine.BPR;
% BPR = 5;

Weng = (Engine.CoreFlow / 45.35) *...
                (1684.5 +...
                17.7 * (Engine.OPR_SLS / 30.0) +...
                1662.2 * (BPR / 5.0)^1.2) / lb_N / 0.453592;
end


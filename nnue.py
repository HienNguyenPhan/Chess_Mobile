import torch
import torch.nn as nn
import chess

class ClippedRelu(nn.Module):
    def forward(self, x):
        return torch.clamp(x, 0.0, 1.0)
    
class FeatureTransformerSlice(nn.Module):
    def __init__(self, num_inputs, num_outputs):
        super().__init__()
        self.num_inputs = num_inputs
        self.num_outputs = num_outputs
        sigma = (1 / num_inputs) ** 0.5
        self.weight = nn.Parameter(torch.rand(num_inputs, num_outputs) * (2 * sigma) - sigma)
        self.bias = nn.Parameter(torch.rand(num_outputs) * (2 * sigma) - sigma)

    def forward(self, feature_indices, feature_values=None):
        if feature_values is None:
            feature_values = torch.ones_like(feature_indices, dtype=torch.float32)
        output = torch.zeros(feature_indices.shape[0], self.num_outputs, device=feature_indices.device)
        for b in range(feature_indices.shape[0]):
            valid_indices = feature_indices[b][feature_indices[b] >= 0]
            valid_values = feature_values[b][:len(valid_indices)]
            output[b] = torch.sum(self.weight[valid_indices] * valid_values.unsqueeze(-1), dim=0) + self.bias
        return output

class NNUE(nn.Module):
    def __init__(self, input_dim=22528, ft_dim=2048, hidden=32, buckets=8):
        super().__init__()
        self.buckets = buckets
        self.ft = FeatureTransformerSlice(input_dim, ft_dim + buckets)  # +PSQT outputs
        self.l1 = nn.Linear(2 * ft_dim, hidden * buckets)  # Wider for subnetworks
        self.l2 = nn.Linear(hidden, hidden * buckets)
        self.output = nn.Linear(hidden, 1 * buckets)

    def forward(self, white_features, black_features, stm, piece_counts):
        wp = self.ft(white_features)
        bp = self.ft(black_features)
        w, wpsqt = torch.split(wp, [wp.shape[1] - self.buckets, self.buckets], dim=1)
        b, bpsqt = torch.split(bp, [bp.shape[1] - self.buckets, self.buckets], dim=1)

        accumulator = stm * torch.cat([w, b], dim=1) + (1 - stm) * torch.cat([b, w], dim=1)
        l1_ = torch.clamp(accumulator, 0.0, 1.0)
        l1_out = self.l1(l1_).view(-1, self.buckets)
        bucket_idx = (piece_counts - 1) // 4
        l1_selected = l1_out[torch.arange(l1_out.shape[0]), bucket_idx]

        l2_ = torch.clamp(self.l2(l1_selected), 0.0, 1.0)
        output = self.output(l2_).view(-1, self.buckets)
        output_selected = output[torch.arange(output.shape[0]), bucket_idx]

        wpsqt_selected = wpsqt[torch.arange(wpsqt.shape[0]), bucket_idx]
        bpsqt_selected = bpsqt[torch.arange(bpsqt.shape[0]), bucket_idx]
        psqt = (wpsqt_selected - bpsqt_selected) * (stm - 0.5)

        return output_selected + psqt
    
def get_feature_indices(board: chess.Board, perspective: bool) -> List[int]:
    """HalfKAv2_hm feature indices with horizontal mirroring."""
    own_color = perspective
    own_king_sq = board.king(own_color)
    if own_king_sq is None:
        return []
    file = own_king_sq % 8
    if file < 4:  # Mirror if king on a-d files
        board = board.mirror()
        own_king_sq = own_king_sq ^ 7
    indices = []
    for sq in chess.SQUARES:
        piece = board.piece_at(sq)
        if piece:
            sq = sq ^ 7 if file < 4 else sq
            color_idx = 0 if piece.color == own_color else 1
            type_idx = piece.piece_type
            bucket = 10 if type_idx == chess.KING else (type_idx - 1) * 2 + color_idx
            idx = sq + (bucket + (own_king_sq % 32) * 11) * 64
            indices.append(idx)
    return indices

def quantize_model(model, path="chess_nnue_quantized.pt"):
    """Quantize model to int8 for inference."""
    model = torch.quantization.quantize_dynamic(
        model, {nn.Linear, FeatureTransformerSlice}, dtype=torch.qint8
    )
    torch.save(model.state_dict(), path)
    return model